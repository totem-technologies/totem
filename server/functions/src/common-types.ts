// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {Timestamp} from "firebase-admin/firestore";
import * as admin from "firebase-admin";

export interface SnapCircleBannedParticipants {
  [uid: string]: {
    bannedOn: Timestamp;
    sessionBan?: {sessionUserId: string; ruleId: number};
  };
}

export interface SnapCircleData {
  name: string;
  createdOn: Timestamp;
  updatedOn: Timestamp;
  startedDate?: Timestamp;
  completedDate?: Timestamp;
  exipresOn?: Timestamp;
  createdBy: admin.firestore.DocumentReference;
  isPrivate: boolean;
  maxMinutes?: number;
  maxParticipants?: number;
  keeper: string;
  state: string;
  description?: string;
  link?: string;
  previewLink?: string;
  previousCircle?: string;
  participantCount?: number;
  circleParticipants?: string[];
  bannedParticipants?: SnapCircleBannedParticipants;
}

export const SessionState = {
  cancelled: "cancelled",
  complete: "complete",
  live: "live",
  waiting: "waiting",
  starting: "starting",
  expiring: "expiring",
  ending: "ending",
};
