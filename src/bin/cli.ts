/**
 * CLI application
 */

import { resolve as resolvePath } from 'path';
import { writeFileSync } from 'fs';

import chalk from 'chalk';
import { Command, Option } from 'commander';
import dashify from 'dashify';
import { first, isEmpty, lowerCase } from 'lodash';
import prompts from 'prompts';

import { GitIgnoreClientBase, GithubClient } from '../lib';
import { ApplicationError } from '@speedup/error';

type ProgramOptions = {
  provider: string; nonInteractive: boolean; write: boolean; output: string; debug: boolean;
};

const providers = {
  [lowerCase(GithubClient.providerName)]: GithubClient
};

const program = new Command('getignore');

const formatNow = () => {
  const now = new Date();
  return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()} ${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`;
}
const Debug = (opts: ProgramOptions) => (message: string, ...args: Array<any>) => opts.debug === true ? console.log(`[${formatNow()}] ${message}`, ...args) : undefined;

// shared parameters
program
  .version('1.0')
  .addOption(
    new Option('-p, --provider <provider>', 'GitIgnore provider name')
      .choices(Object.keys(providers).map(lowerCase))
      .default(first(Object.keys(providers)))
  )
  .option('-d, --debug', 'Show debug statements', false)
  .option('-o, --output [name]', 'Output file name', '.gitignore')
  .option('-w, --write', 'Write to stdout', false)
  .option('--non-interactive', 'Run in non-interactive mode', false);

// default action
program
  .argument('<name>', 'Language/Framework name (e.g. node)')
  .description('Download gitignore file for the language/framework of your choice')
  .action(async (name: string, opts: ProgramOptions) => {

    const debug = Debug(opts);
    let provider: GitIgnoreClientBase = new providers[opts.provider]();
    let selectedTemplateName: string | undefined = undefined;
    let found = false;
    let showSuggestion = false;

    // fetch all available options & create a consistent searchable array
    debug('Fetching list of available gitignore files...');
    const gitIgnoreFileList = await provider.fetchAllAvailableFiles();
    debug(`Total number of ${gitIgnoreFileList.length} gitignore files was found.`);

    // user input was exactly matched
    const userInputExactlyMatchIndex = gitIgnoreFileList.map(file => file.name.toLowerCase()).indexOf(name.toLowerCase());
    const userInputExactlyMatched = userInputExactlyMatchIndex > -1;
    debug(`User input matched: ${userInputExactlyMatched === true ? chalk.green(true) : chalk.yellow(false)}`);

    if (userInputExactlyMatched === true) {
      selectedTemplateName = gitIgnoreFileList[userInputExactlyMatchIndex].name;
      debug(`User selected template: ${chalk.green(selectedTemplateName)}`);

      found = true;
      showSuggestion = false;
    }

    // user input was not matched or partially matched
    if (userInputExactlyMatched === false) {
      // determine to show suggestion
      showSuggestion = opts.nonInteractive === false;
      debug(`Show suggestion: ${showSuggestion === true ? chalk.green(true) : chalk.red(false)}`);
    }

    // show the suggestion
    if (showSuggestion === true) {
      debug(`Creating autocomplete list of files...`);
      // ask user to select proper template
      const promptResult = await prompts({
        name: 'selectedTemplate',
        message: 'Please choose template: ',
        type: 'autocomplete',
        choices: gitIgnoreFileList.map((suggestion, index) => ({ title: suggestion.name, value: index }))
      });

      if (isEmpty(promptResult)) {
        console.error(`User canceled the operation.`);
        return process.exit(2);
      }

      // update the selected template name
      selectedTemplateName = gitIgnoreFileList[promptResult.selectedTemplate].name;
      debug(`User selected template: ${chalk.green(selectedTemplateName)}`);
      found = true;
    }

    // neither found nor selected by user
    if (found === false) {
      console.error(chalk.red(`No template found for the requested language/framework ('${name}').`));
      return process.exit(1);
    }

    let content: Buffer | undefined = undefined;

    try {

      debug('Downloading gitignore file content...');

      // retrieve file from the provider
      content = await provider.fetchGitIgnoreFile(selectedTemplateName!);
    }
    catch (err) {
      // handled application error
      if (err instanceof ApplicationError) {
        switch (err.code) {
          case 'E_NOT_FOUND': {
            found = false;
            console.error(chalk.red(`Failed to download '${selectedTemplateName}' from provider named ${opts.provider}.`));
            break;
          }
        }
      } else {
        // unhandled error
        throw err;
      }
    }
    finally {
      if (found === false) {
        process.exit(1);
      }
    }

    // write to stdout
    if (opts.write) {
      debug('Writing to stdout...');
      process.stdout.write(content!);
      return process.exit(0);
    }

    const resolvedOutputFilePath = resolvePath(opts.output);
    debug(`Writing content to '${chalk.green(resolvedOutputFilePath)}' ...`);

    // write to disk
    writeFileSync(resolvedOutputFilePath, content!, { encoding: 'utf-8' });

    debug(`Done.`);
  });

// parse the arguments
program
  .showHelpAfterError()
  .parse(process.argv);
