import { RESOURCE_NAME } from "../components/shared/utils/constants";

export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown
): Promise<T> {
  const resp = await fetch(`https://${RESOURCE_NAME}/${eventName}`, {
    method:  "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body:    JSON.stringify(data),
  });

  if (!resp.ok) {
    throw new Error(`NUI ${eventName}: ${resp.status} ${resp.statusText}`);
  }

  return resp.json() as Promise<T>;
}
