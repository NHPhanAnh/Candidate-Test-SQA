import moment from "moment-timezone";

/**
 * Convert either an epoch (seconds) or a time string into a formatted string.
 *
 * @param input - Epoch in seconds OR a date string
 * @param format - Desired output format (e.g. "YYYY-MM-DD HH:mm:ss")
 * @param timezone - Optional IANA timezone string (e.g. "Asia/Tokyo")
 * @returns Formatted date string
 */
export function formatDateTime(
  input: number | string,
  format: string,
  timezone?: string,
): string {
  if (!input) {
    return "";
  }
  let m: moment.Moment;

  if (typeof input === "number") {
    m = moment.unix(input);
  } else {
    m = moment(input);
  }

  if (timezone) {
    m = m.tz(timezone);
  }

  return m.format(format);
}

export function toUtcDate(dateString: string): string {
  return moment(dateString)
    .utc() // convert to UTC
    .startOf("day") // set time to 00:00:00
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toUtcDateWithTime(dateString: string): string {
  return moment(dateString)
    .utc() // convert to UTC
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toDate(dateString: string): string {
  return moment(dateString)
    .startOf("day") // set time to 00:00:00
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toUtcDateStart(dateString: string): string {
  return moment(dateString)
    .startOf("day") // set time to 00:00:00 in local time FIRST
    .utc() // THEN convert to UTC
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toDateStart(dateString: string): string {
  return moment(dateString)
    .startOf("day") // set time to 00:00:00 in local time FIRST
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toUtcDateEnd(dateString: string): string {
  return moment(dateString)
    .endOf("day") // set time to 23:59:59.999 in local time FIRST
    .utc() // THEN convert to UTC
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function toDateEnd(dateString: string): string {
  return moment(dateString)
    .endOf("day") // set time to 23:59:59.999 in local time FIRST
    .format("YYYY-MM-DDTHH:mm:ss[Z]");
}

export function getLocalWeek() {
  const startOfWeek = moment().startOf("isoWeek");
  const endOfWeek = moment().endOf("isoWeek");

  return {
    start: startOfWeek.format("YYYY/MM/DD"),
    end: endOfWeek.format("YYYY/MM/DD"),
  };
}
