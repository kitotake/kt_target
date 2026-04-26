import { RESOURCE_NAME } from "../config";

export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown
): Promise<T> {
  const resp = await fetch(`https://${RESOURCE_NAME}/${eventName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data),
  });

  return resp.json() as Promise<T>;
}