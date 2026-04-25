const resource = (window as any).GetParentResourceName?.() ?? "nui-resource";

export async function fetchNui<T = any>(
  eventName: string,
  data?: any
): Promise<T> {
  const resp = await fetch(`https://${resource}/${eventName}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  });

  return resp.json();
}