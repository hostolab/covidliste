#!/usr/bin/env node

"use strict";

const fs = require("fs");
const PDFDocument = require("pdfkit");
const doc = new PDFDocument({
  margin: 0,
  autoFirstPage: false,
  "disable-smart-shrinking": "",
});

const data = JSON.parse(process.argv[2]);

const jobs = data["jobs"];
const cwd = data["cwd"];
const browser_dir = data["browser_dir"];

const pdf_output_file = cwd + "/output.pdf";
const stream = doc.pipe(fs.createWriteStream(pdf_output_file));
stream.on("finish", function () {
  process.exit();
});
console.log(pdf_output_file);

function waitForFrameLoaded(frame) {
  let fulfill;
  const promise = new Promise((x) => (fulfill = x));
  frame._frameManager.on("Events.FrameManager.LifecycleEvent", checkFrame);
  checkFrame(frame);
  return promise;

  function checkFrame(eventFrame) {
    if (eventFrame == frame) {
      // console.log(eventFrame._lifecycleEvents);
      if (eventFrame._lifecycleEvents.has("DOMContentLoaded")) {
        fulfill(frame);
      }
    }
  }
}

const puppeteer = require("puppeteer");

const work = async (worker) => {
  let browser;
  try {
    browser = await puppeteer.launch({
      devtools: false,
      headless: false,
      slowMo: 250,
      defaultViewport: null,
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--window-size=850,2160",
        "--window-position=0,0",
      ],
      userDataDir: browser_dir,
      dumpio: true,
    });
    const page = await browser.newPage();
    page.on("console", (msg) => console.log("PAGE LOG:", msg.text()));
    console.log('worker["url"]: ' + worker["url"]);
    await page.goto(worker["url"], {
      timeout: 15000,
      waitUntil: "networkidle2",
    });
    const frameElement = await page.waitForSelector(
      'iframe[name="messageBody"]'
    );
    const iframe = await frameElement.contentFrame();
    await waitForFrameLoaded(iframe);
    var bannerHeight = await page.evaluate(() => {
      var domBullets = document.querySelectorAll("#bullet-footer");
      var domHeaderItems = [
        ...document.querySelectorAll("body > header dt"),
      ].filter(
        (e) =>
          e.textContent.includes("SMTP-To") ||
          e.textContent.includes("Date") ||
          e.textContent.includes("Format") ||
          e.textContent.includes("Locale") ||
          e.textContent.includes("To")
      );
      var domHeader = document.querySelector("body > header");
      if (domBullets.length > 0) {
        Array.prototype.forEach.call(domBullets, function (node) {
          node.parentNode.removeChild(node);
        });
      }
      Array.prototype.forEach.call(domHeaderItems, function (node) {
        var siblingNode = node.nextElementSibling || node.nextSibling;
        node.parentNode.removeChild(node);
        siblingNode.parentNode.removeChild(siblingNode);
      });
      return Math.max(
        domHeader.offsetHeight,
        domHeader.clientHeight,
        domHeader.scrollHeight
      );
    });
    var iframeHeight = await iframe.evaluate(() => {
      var domBullets = document.querySelectorAll("#bullet-footer");
      var domContent = document.querySelector("body > div");
      if (domBullets.length > 0) {
        Array.prototype.forEach.call(domBullets, function (node) {
          node.parentNode.removeChild(node);
        });
      }
      return Math.max(
        domContent.offsetHeight,
        domContent.clientHeight,
        domContent.scrollHeight
      );
    });
    var documentHeight = iframeHeight + bannerHeight;
    // console.log("iframeHeight: " + iframeHeight);
    // console.log("bannerHeight: " + bannerHeight);
    // console.log("documentHeight: " + documentHeight);
    await page.setViewport({
      width: 850,
      height: documentHeight,
      deviceScaleFactor: 2,
    });
    await page.screenshot({
      path: worker["path"],
      type: "jpeg",
      quality: 100,
      clip: { x: 0, y: 0, width: 850, height: documentHeight },
    });
    var img = doc.openImage(worker["path"]);
    doc.addPage({ size: [img.width, img.height + 40] });
    doc
      .fontSize(18)
      .fillColor("#d9215f")
      .text(`[${worker["locale"]}] ${worker["name"]}`, 20, 20);
    doc.image(img, 0, 40);

    console.log("Saved to : " + worker["path"]);
  } catch (err) {
    console.log(err.message);
  } finally {
    if (browser) {
      browser.close();
    }
    if (jobs.length) {
      work(jobs.pop());
    } else {
      doc.end();
    }
  }
};

work(jobs.pop());
