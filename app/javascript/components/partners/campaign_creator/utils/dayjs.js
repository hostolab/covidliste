import dayjs from "dayjs";
import utcPlugin from "dayjs/plugin/utc";
import timezonePlugin from "dayjs/plugin/timezone";

dayjs.extend(utcPlugin);
dayjs.extend(timezonePlugin);

const timezoneOffset = (timezone) => dayjs.tz(undefined, timezone).$offset / 60;

export const utcTimezone = (timezone) => {
  const offset = timezoneOffset(timezone);
  if (offset > 0) {
    return `UTC + ${offset}`;
  } else if (offset < 0) {
    return `UTC - ${offset}`;
  } else {
    return `UTC`;
  }
};

export default dayjs;
