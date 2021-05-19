import { config, library, dom } from "@fortawesome/fontawesome-svg-core";

config.mutateApproach = "sync"; // Change the config to fix the flicker

// import { faUser } from "@fortawesome/free-regular-svg-icons";

import {
  faEye,
  faUser,
  faEdit,
  faTimes,
  faTrash,
  faTools,
  faPhone,
  faCheck,
  faSyringe,
  faUserPlus,
  faEnvelope,
  faThumbsUp,
  faUserCheck,
  faUserTimes,
  faInfoCircle,
  faPaperPlane,
  faHospitalUser,
  faChevronRight,
  faMapMarkedAlt,
  faExternalLinkAlt,
} from "@fortawesome/free-solid-svg-icons";

import {
  faGithub,
  faTwitter,
  faFacebook,
  faInstagram,
  faLinkedin,
} from "@fortawesome/free-brands-svg-icons";

library.add(
  faEye,
  faUser,
  faEdit,
  faTimes,
  faTrash,
  faTools,
  faPhone,
  faCheck,
  faSyringe,
  faUserPlus,
  faEnvelope,
  faThumbsUp,
  faUserCheck,
  faUserTimes,
  faInfoCircle,
  faPaperPlane,
  faHospitalUser,
  faChevronRight,
  faMapMarkedAlt,
  faExternalLinkAlt,

  faGithub,
  faTwitter,
  faFacebook,
  faInstagram,
  faLinkedin
);

dom.watch();
