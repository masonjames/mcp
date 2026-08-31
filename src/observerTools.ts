import { z } from "zod";
import type { ToolDefinition } from "./types.js";

const applicationId = z.object({ applicationId: z.string().min(1) });

export const observerTools: ToolDefinition[] = [
  {
    name: "application-immutableReleaseSnapshot",
    description: "GET /application.immutableReleaseSnapshot",
    tag: "releaseObserver",
    method: "GET",
    path: "/application.immutableReleaseSnapshot",
    schema: applicationId,
    annotations: {
      title: "Application Immutable Release Snapshot",
      readOnlyHint: true,
      idempotentHint: true,
      openWorldHint: true,
    },
  },
  {
    name: "application-runtimeStatus",
    description: "GET /application.runtimeStatus",
    tag: "releaseObserver",
    method: "GET",
    path: "/application.runtimeStatus",
    schema: applicationId,
    annotations: {
      title: "Application Runtime Status",
      readOnlyHint: true,
      idempotentHint: true,
      openWorldHint: true,
    },
  },
];
