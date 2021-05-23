import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";

dayjs.extend(utc);
dayjs.extend(timezone);

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
