export function getLocaleNumber(num: number): string {
  if (num === null || num === undefined || Number.isNaN(num)) return "";
  return new Intl.NumberFormat(undefined).format(num);
}
