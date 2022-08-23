import * as functions from "firebase-functions";
import {AuthData} from "firebase-functions/lib/common/providers/https";

export enum Role {
  MEMBER = "member",
  KEEPER = "keeper",
  ADMIN = "admin",
}

/**
 * Checks if the `auth` object exists, and has a uid. Returns a non-null auth object.
 * @param {AuthData | undefined} auth
 * @param {Role[] | undefined} roles
 * @return {AuthData}
 */
export function isAuthenticated(auth: AuthData | undefined, roles: Role[] | undefined = undefined): AuthData {
  if (!auth || !auth.uid) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }
  if (roles && roles.length > 0) {
    if (!hasAnyRole(auth, roles)) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        `The function must be called by a user with one of the roles: ${roles.join(", ")}.`
      );
    }
  }
  return auth;
}

/**
 * Checks to see if the user has any of the roles in the `roles` array.
 * @param {AuthData} auth
 * @param {Role[]} roles
 * @return {boolean}
 */
export function hasAnyRole(auth: AuthData, roles: Role[]): boolean {
  return auth.token.roles && roles.some((r) => auth.token.roles.includes(r));
}
