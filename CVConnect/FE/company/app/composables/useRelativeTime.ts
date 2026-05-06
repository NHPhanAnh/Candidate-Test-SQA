import { ref, onMounted, onBeforeUnmount } from "vue";
import moment from "moment-timezone";
import "moment/locale/vi";

// Set the locale globally

export function useMomentRelativeTime(
  timestamp: number | string,
  timezone?: string,
) {
  const relative = ref("");

  function updateTime() {
    if (!timestamp) {
      relative.value = "";
      return;
    }

    const time =
      typeof timestamp === "number" && timestamp < 1e12
        ? moment.unix(timestamp)
        : moment(timestamp);

    const localizedTime = timezone ? time.tz(timezone) : time;

    moment.updateLocale("vi", {
      relativeTime: {
        future: "Trong %s",
        past: "%s trước",
        s: "vài giây",
        ss: "%d giây",
        m: "1 phút",
        mm: "%d phút",
        h: "1 giờ",
        hh: "%d giờ",
        d: "1 ngày",
        dd: "%d days",
        w: "a week",
        ww: "%d weeks",
        M: "a month",
        MM: "%d months",
        y: "a year",
        yy: "%d years",
      },
    });

    const diffDays = moment().diff(localizedTime, "days");

    if (diffDays >= 1) {
      relative.value = localizedTime.format("DD/MM/YYYY - HH:mm");
    } else {
      relative.value = localizedTime.locale("vi").fromNow();
    }
  }

  onMounted(() => {
    updateTime();
    const interval = setInterval(updateTime, 60 * 1000);
    onBeforeUnmount(() => clearInterval(interval));
  });

  return relative;
}
