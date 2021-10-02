/**
 * Github gitignore client
 */

import axios from 'axios';
import { ApplicationError } from '@speedup/error';

import { GitIgnoreClientBase, GitIgnoreFile } from './gitignore-client';

export class GithubClient extends GitIgnoreClientBase {

  static readonly providerName: string = 'Github';

  protected readonly httpClient = axios.create({
    baseURL: 'https://api.github.com/gitignore/templates',
    headers: {
      'Accept': 'application/vnd.github.v3+json'
    }
  });

  async fetchAllAvailableFiles(): Promise<GitIgnoreFile[]> {
    const availableTemplatesList = await this.httpClient.get<Array<string>>('', { validateStatus: statusCode => statusCode === 200 });

    return availableTemplatesList.data.map(name => ({
      name
    }));
  }

  async fetchGitIgnoreFile(name: string): Promise<Buffer> {
    const response = await this.httpClient.get<{ name: string; source: string; }>(`/${name}`, { validateStatus: statusCode => statusCode === 404 || statusCode === 200 });

    if (response.status === 404) {
      throw new ApplicationError({ code: 'E_NOT_FOUND', message: 'Gitignore file was not found' });
    }

    return Buffer.from(response.data.source);
  }
}