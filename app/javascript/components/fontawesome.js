import { config, library, dom } from "@fortawesome/fontawesome-svg-core";

config.mutateApproach = "sync"; // Change the config to fix the flicker

import { faUser } from "@fortawesome/free-regular-svg-icons";

import {
  faPaperPlane,
  faHospitalUser,
  faCheck,
  faTimes,
  faEdit,
  faTrash,
  faPhone,
  faInfoCircle,
  faChevronRight,
  faTools,
  faExternalLinkAlt,
  faUserPlus,
  faEnvelope,
  faUserCheck,
  faUserTimes,
  faArrowLeft,
  faSyringe,
  faUserMd,
  faClinicMedical,
  faEye,
  faThumbsUp,
} from "@fortawesome/free-solid-svg-icons";

import {
  faGithub,
  faTwitter,
  faFacebook,
  faInstagram,
  faLinkedin,
} from "@fortawesome/free-brands-svg-icons";

library.add(
  faUser,

  faPaperPlane,
  faHospitalUser,
  faCheck,
  faTimes,
  faEdit,
  faTrash,
  faPhone,
  faInfoCircle,
  faChevronRight,
  faTools,
  faExternalLinkAlt,
  faUserPlus,
  faEnvelope,
  faUserCheck,
  faUserTimes,
  faArrowLeft,
  faSyringe,
  faUserMd,
  faClinicMedical,
  faEye,
  faThumbsUp,

  faGithub,
  faTwitter,
  faFacebook,
  faInstagram,
  faLinkedin
);

dom.watch();
