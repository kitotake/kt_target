import { RESOURCE_NAME } from "../config";

export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown
): Promise<T> {
  try {
    const resp = await fetch(`https://${RESOURCE_NAME}/${eventName}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify(data),
    });

    if (!resp.ok) {
      throw new Error(`NUI error: ${resp.status} ${resp.statusText}`);
    }

    return (await resp.json()) as T;
  } catch (err) {
    console.error(`[fetchNui] ${eventName} failed:`, err);
    throw err;
  }
}