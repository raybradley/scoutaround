import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "attachmentList", "attachmentWrapper", "attachmentForm", "audienceList", "audienceName",
                     "ffCheckWrapper", "fileInput",
                     "recipientList", "memberTypeCheckBox", "memberStatusCheckBox", "subjectTextBox", "bodyTextArea",
                     "sendMessageButton", "sendLaterButton", "sendPreviewButton", "tempFileInput",
                     "searchResults" ];
  static values = { unitId: Number };

  files= [];

  connect() {
    // this.updateRecipients();
    this.validate();
  }

  updateRecipients() {
    console.log("updateRecipients");
    const selectedRadioButton = document.querySelector("input[type='radio']:checked");
    const audience = selectedRadioButton.value;
    const memberType = this.memberTypeCheckBoxTarget.checked ? "adults_only" : "youth_and_adults";
    const memberStatus = this.memberStatusCheckBoxTarget.checked ? "active_and_registered" : "active";
    
    var audienceName = selectedRadioButton.dataset.messageFormAudienceName;

    if (audience === "everyone") {
      if (memberStatus === "active_and_registered") {
        audienceName = "All " + audienceName;
      } else {
        audienceName = "Active " + audienceName;
      } 
    }

    if (memberType === "adults_only") {
      audienceName = "Adult " + audienceName;
    }

    this.audienceNameTarget.textContent = audienceName;    

    // hide the ff check box if the audience is not everyone
    this.ffCheckWrapperTarget.classList.toggle("hidden", audience !== "everyone");

    // https://www.reddit.com/r/rails/comments/rzne63/is_it_possible_to_trigger_turbo_stream_update/

    // post a call to an endpoint to compute the recipient list

    const body = {
      "audience":      audience,
      "member_type":   memberType,
      "member_status": memberStatus,
    }    

    post(`/u/${this.unitIdValue}/email/recipients`, { body: body, responseKind: "turbo-stream" });
  }

  hideRecipientList() {
    this.recipientListTarget.classList.toggle("hidden", true);
  }

  searchRecipients(event) {
    const body = {
      "query": event.target.value
    }

    const path = `/u/${this.unitIdValue}/email/recipients`;

    console.log(path);
    console.log(body);

    post(`/u/${this.unitIdValue}/email/search`, { body: body, responseKind: "turbo-stream" });
  }

  toggleRecipientList(event) {
    this.recipientListTarget.classList.toggle("hidden");
    event.preventDefault();
  }

  toggleFormattingToolbar (event) {
    this.element.classList.toggle("formatting-active");
    event.preventDefault();
  }

  addAttachments(event) {
    this.files.push(event.target.files);
    console.log(this.files);
    this.attachmentWrapperTarget.classList.toggle("hidden", false);
  }

  uploadFiles() {
    const files = this.fileInputTarget.click();
  }

  validate() {
    var valid = this.subjectTextBoxTarget.value.length > 0;
    valid = valid && this.bodyTextAreaTarget.value.length > 0;

    this.sendMessageButtonTarget.disabled = !valid;
    this.sendLaterButtonTarget.disabled   = !valid;
    this.sendPreviewButtonTarget.disabled = !valid;
  }

  changeAudience(event) {
    const target = this.target;
    const audienceValue = target.dataset.messageFormAudienceValue;
    
    this.audienceListTarget.querySelectorAll("li").forEach((li) => {
      li.classList.toggle("active", false);
    });
    event.target.closest("li").classList.toggle("active", true);

    event.preventDefault();
  }
}
