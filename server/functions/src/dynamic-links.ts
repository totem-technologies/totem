import {request, RequestOptions} from "https";
import {ShortLinkRequestBody, ShortLinkResponse} from "./short-links-api";
import {LinkStatsResponse} from "./link-stats-api";

/** Firebase Dynamic Link support */
export class FirebaseDynamicLinks {
  private readonly webApiKey!: string;

  /**
   * @constructor
   * @param {string} webApiKey API key to authenticate your requests to the API.
   * Take note of your project `Web Api Key` from [setting page](https://console.firebase.google.com/project/_/settings/general/) of the Firebase console.
   */
  constructor(webApiKey: string) {
    if (webApiKey == null) {
      throw new Error("Firebase Dynamic Links: Web Api Key can not be null or undefined");
    }

    this.webApiKey = webApiKey;
  }

  /**
   * You can use this function to generate short Dynamic Links.
   * @param {object} body read full documentation [here](https://firebase.google.com/docs/reference/dynamic-links/link-shortener#request_body)
   * @param {string} refererSrc The source function calling
   * @return {object} read full documentation [here](https://firebase.google.com/docs/reference/dynamic-links/link-shortener#response_body)
   */
  async createLink(body: ShortLinkRequestBody, refererSrc: string): Promise<ShortLinkResponse> {
    const data: string = JSON.stringify(body);
    const referer: string = "https://" + process.env.GCLOUD_PROJECT + ".cloudfunctions.net/" + refererSrc;
    const options: RequestOptions = {
      hostname: "firebasedynamiclinks.googleapis.com",
      path: `/v1/shortLinks?key=${this.webApiKey}`,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Referer: referer,
      },
    };

    return new Promise((resolve, reject) => {
      const req = request(options, (res) => {
        const buffers: Buffer[] = [];
        res
          .on("data", (chunk) => {
            buffers.push(chunk);
          })
          .on("end", () => {
            const d = Buffer.concat(buffers).toString();
            const resBody = JSON.parse(d);
            if (res.statusCode === 200) {
              resolve(resBody);
            } else {
              reject(resBody);
            }
          });
      });

      req.on("error", reject);
      req.write(data);
      req.end();
    });
  }

  /**
   * Use the this function to get event statistics for a single Dynamic Link.
   * @param {string} shortDynamicLink The URL-encoded short Dynamic Link for which you want to get event data. read full documentation [here](https://firebase.google.com/docs/reference/dynamic-links/analytics#http_request)
   * @param {number} duration The number of days for which to get event data. read full documentation [here](https://firebase.google.com/docs/reference/dynamic-links/analytics#http_request)
   * @param {accessToken} accessToken An unexpired access token. read full documentation [here](https://firebase.google.com/docs/reference/dynamic-links/analytics#api_authorization)
   * @return {any} read full documentation [here](https://firebase.gogle.com/docs/reference/dynamic-links/analytics#response_body)
   */
  async getLinkStats(shortDynamicLink: string, duration: number, accessToken: string): Promise<LinkStatsResponse> {
    const options: RequestOptions = {
      hostname: "firebasedynamiclinks.googleapis.com",
      path: `/v1/${encodeURIComponent(shortDynamicLink)}/linkStats?durationDays=${duration}`,
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    };

    return new Promise((resolve, reject) => {
      const req = request(options, (res) => {
        const buffers: Buffer[] = [];
        res
          .on("data", (chunk) => {
            buffers.push(chunk);
          })
          .on("end", () => {
            const d = Buffer.concat(buffers).toString();
            const resBody = JSON.parse(d);
            if (res.statusCode === 200) {
              resolve(resBody);
            } else {
              reject(resBody);
            }
          });
      });

      req.on("error", reject);
      req.end();
    });
  }
}
