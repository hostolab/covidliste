import { config, library, dom } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";
import {
  faGithub as fabFaGithub,
  faTwitter as fabFaTwitter,
  faFacebook as fabFaFacebook,
  faInstagram as fabFaInstagram,
  faLinkedin as fabFaLinkedin,
} from "@fortawesome/free-brands-svg-icons";

config.mutateApproach = "sync";
library.add(
  fas,
  fabFaGithub,
  fabFaTwitter,
  fabFaFacebook,
  fabFaInstagram,
  fabFaLinkedin
);
dom.watch();
