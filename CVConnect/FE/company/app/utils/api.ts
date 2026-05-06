export function objectToQuery(obj: Record<string, any>): string {
  return new URLSearchParams(
    Object.fromEntries(
      Object.entries(obj)
        .filter(
          ([_, value]) =>
            value !== undefined &&
            value !== null &&
            value !== "" &&
            !(Array.isArray(value) && value.length === 0),
        )
        .map(([key, value]) => [key, String(value)]),
    ),
  ).toString();
}

export function truncateQueryObject(obj: Record<string, any>) {
  return Object.fromEntries(
    Object.entries(obj)
      .filter(
        ([_, value]) =>
          value !== undefined &&
          value !== null &&
          value !== "" &&
          !(Array.isArray(value) && value.length === 0),
      )
      .map(([key, value]) => [key, String(value)]),
  );
}
