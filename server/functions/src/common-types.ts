// eslint-disable-next-line import/no-unresolved -- https://github.com/firebase/firebase-admin-node/issues/1827#issuecomment-1226224988
import {DocumentReference, Timestamp} from "firebase-admin/firestore";

export enum SessionState {
  cancelling = "cancelling",
  cancelled = "cancelled",
  complete = "complete",
  live = "live",
  waiting = "waiting",
  starting = "starting",
  expiring = "expiring",
  expired = "expired",
  ending = "ending",
  scheduled = "scheduled",
}

export enum RecurringType {
  none = "none",
  instances = "instances",
  repeating = "repeating",
}

export enum RepeatUnit {
  hours = "hours",
  days = "days",
  weeks = "weeks",
  months = "months",
}

export interface RepeatOptions {
  start?: Timestamp;
  every?: number;
  unit?: RepeatUnit;
  until?: Timestamp;
  count?: number;
}

export interface SnapCircleBannedParticipants {
  [uid: string]: {
    bannedOn: Timestamp;
    sessionBan?: {sessionUserId: string; ruleId: number};
  };
}

export interface SnapCircleData {
  name: string;
  description?: string;
  createdBy: DocumentReference;
  createdOn: Timestamp;
  updatedOn: Timestamp;
  exipresOn?: Timestamp;
  participantCount?: number;
  maxParticipants?: number;
  maxMinutes?: number;
  link?: string;
  previewLink?: string;
  keeper: string;
  previousCircle?: string;
  bannedParticipants?: SnapCircleBannedParticipants;
  themeRef?: string;
  imageUrl?: string;
  bannerImageUrl?: string;
  isPrivate: boolean;
  nextSession?: Timestamp;
  scheduledSessions?: Timestamp[];
  repeating?: RepeatOptions;

  state: SessionState;
  startedDate?: Timestamp;
  completedDate?: Timestamp;
  circleParticipants?: string[];
}

export interface CircleSessionSummary {
  startedDate?: Timestamp;
  completedDate?: Timestamp;
  state: string;
  circleParticipants?: string[];
}

export interface CreateSnapCircleArgs {
  name: string;
  description: string;
  previousCircle?: string;
  bannedParticipants?: SnapCircleBannedParticipants;
  themeRef?: string;
  imageUrl?: string;
  bannerImageUrl?: string;
  options?: {
    isPrivate: boolean;
    maxMinutes?: number;
    maxParticipants?: number;
    recurringType?: RecurringType;
    instances?: Timestamp[];
    repeating?: RepeatOptions;
  };
}

export interface Participant {
  joined: Timestamp;
  name: string;
  sessionUserId: string;
  uid: string;
  role: string;
}
