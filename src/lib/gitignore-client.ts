/**
 * Gitignore service client
 */

export type GitIgnoreFile = {
  name: string;
};

export abstract class GitIgnoreClientBase {

  abstract fetchAllAvailableFiles(): Promise<Array<GitIgnoreFile>>;
  abstract fetchGitIgnoreFile(name: string): Promise<Buffer>;
}
