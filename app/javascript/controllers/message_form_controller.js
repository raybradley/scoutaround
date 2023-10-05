import { DirectUpload } from "@rails/activestorage"
import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import {} from "../traversal.js"

// https://mentalized.net/journal/2020/11/30/upload-multiple-files-with-rails/
// config.active_storage.replace_on_assign_to_many = false
// https://blog.commutatus.com/understanding-rails-activestorage-direct-uploads-a4aeca7eccf

export default class extends Controller {
  static targets = [ "attachmentsList", "attachmentsWrapper", "attachmentForm", "audienceList", "audienceName",
                     "ffCheckWrapper", "fileInput", "form",
                     "addressBook", "memberTypeCheckBox", "memberStatusCheckBox", "subjectTextBox", "bodyTextArea",
                     "sendMessageButton", "sendLaterButton", "sendPreviewButton", "tempFileInput",
                     "queryInput", "addressBook", "recipientList" ];
  static values = { unitId: Number };

  recipientObserver = null;
  dirty = false;
  browsingAddressBook = false;
  shouldSkipLeaveConfirmation = false;

  connect() {
    this.establishRecipientObserver();
    this.establishAttachmentsObserver();
    this.validate();
    this.formData = new FormData(this.formTarget);
  }

  blur() { }

  browseAddressBook(event) {
    event.preventDefault();
    if (this.browsingAddressBook) { 
      this.closeAddressBook();
    } else {
      this.openAddressBook(true);
    }
    this.browsingAddressBook = !this.browsingAddressBook;
  }

  skipLeaveConfirmation() {
    this.shouldSkipLeaveConfirmation = true;
  }

  addAttachments(event) {
    this.attachmentFormTarget.requestSubmit();
  }

  confirmLeave(event) {
    if (this.shouldSkipLeaveConfirmation) { return; }

    if (this.dirty && !confirm("You have unsaved changes. Are you sure you want to leave this page?")) {
      event.preventDefault();
      event.returnValue = "";
    }
  }

  establishRecipientObserver() {
    this.recipientObserver = new MutationObserver((mutations) => {
      this.validate();
      this.syncAddressBookToRecipients();
    });
    this.recipientObserver.observe(this.addressBookTarget, { childList: true });
  }

  establishAttachmentsObserver() {
    this.attachmentObserver = new MutationObserver((mutations) => {
      this.attachmentsWrapperTarget.classList.toggle("hidden", this.attachmentsListTarget.children.length == 0);
    });
    this.attachmentObserver.observe(this.attachmentsListTarget, { childList: true });
  }

  handleKeydown(event) {
    if (event.key === "Backspace" && (event.metaKey || event.ctrlKey)) {
      this.recipientListTarget.querySelectorAll(".recipient").forEach((tag) => {
        tag.remove();
      });
      return;
    } else if (event.key === "Backspace") {
      if (this.queryInputTarget.value.length > 0) { return; }
      this.deleteLastRecipient();
      this.validate();
      return;
    }

    const current = this.addressBookTarget.querySelector(".selected");
    if (!current) { return; }

    if (event.key === "ArrowUp") {
      var target = current.prev(".contactable:not(.hidden)", true);
      // var target = current.previousSibling;
      // if (target == null) { target = current.parentNode.lastChild; } // wraparoun
      // while(target) {
      //   if (target.classList.contains("contactable")) { break; }
      //   target = target.previousSibling;
      //   if (target == null) { target = current.parentNode.lastChild; } // wraparound
      // }
      current.classList.remove("selected");
      target?.classList?.add("selected");
      target?.scrollIntoView({block: "center"});
      event.stopPropagation();
      event.preventDefault();
    } else if (event.key === "ArrowDown") {
      var target = current.next(".contactable:not(.hidden)", true);
      // var target = current.nextSibling;
      // if (target == null) { target = current.parentNode.firstChild; } // wraparound
      // while(target) {
      //   if (target.classList.contains("contactable")) { break; }
      //   target = target.nextSibling;
      //   if (target == null) { target = current.parentNode.firstChild; } // wraparound
      // }
      current.classList.remove("selected");
      target?.classList?.add("selected");
      target?.scrollIntoView({block: "center"});
      event.stopPropagation();
      event.preventDefault();
    } else if ((event.key === "Enter" || event.key === "Tab") && this.addressBookIsOpen()) {
      this.commit();
      event.stopPropagation();
      event.preventDefault();
    } else if (event.key === "Escape") {
      this.closeAddressBook();
      event.stopPropagation();
      event.preventDefault();
    } else { return; }
  }

  deleteLastRecipient() {
    const lastElem = this.queryInputTarget.parentNode.previousSibling;
    if (!lastElem) { return; }
    lastElem.remove();
  }

  async commit() {
    this.queryInputTarget.placeholder = "";
    const current = this.addressBookTarget.querySelector(".selected");
    const recipientTags = this.addressBookTarget.querySelectorAll(".recipient");
    const memberIds = Array.from(recipientTags).map((tag) => { return tag.dataset.recipientId; });

    const body = { "key": current.dataset.key, "member_ids": memberIds }

    await post(`/u/${this.unitIdValue}/messages/commit`, { body: body, responseKind: "turbo-stream" });    

    this.markAsDirty();
    this.resetQueryInput();
    this.closeAddressBook();
    this.queryInputTarget.focus();
  }

  deleteItem(event) {
    const target = event.target;
    target.closest(".recipient").remove();
  }

  /* address book */

  closeAddressBook() {
    this.addressBookTarget.classList.toggle("hidden", true);
  }

  openAddressBook() {
    this.addressBookTarget.classList.toggle("hidden", false);
  }

  addressBookIsOpen() {
    return !this.addressBookTarget.classList.contains("hidden");
  }
  
  filterAddressBook(browse = false) {
    this.openAddressBook();

    this.addressBookTarget.querySelectorAll("li").forEach((li) => {
      // var name = nameCell.innerText.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
      // if (filter.length == 0 || name.toUpperCase().indexOf(filter) > -1) {
        
        const filter = this.queryInputTarget.value.toUpperCase();
        const name = li.innerText.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
        var match = false;
        
        match = match || filter.length == 0;
        match = match || name.toUpperCase().indexOf(filter) > -1;
        
        li.classList.remove("selected");
        li.classList.toggle("hidden", !match);
      }
    );

    this.addressBookTarget.querySelector("li.contactable:not(.hidden)")?.classList?.toggle("selected", true);
  }

  unfilterAddressBook() {
    this.addressBookTarget.querySelectorAll("li").forEach((li) => {        
        li.classList.toggle("hidden", false);
    } );
  } 

  syncAddressBookToRecipients() {
    this.unfilterAddressBook();
    const memberIds = this.selectedMemberIds();

    memberIds.forEach((memberId) => {
      const li = this.addressBookTarget.querySelector(`li[id='membership_${memberId}']`);
      li?.classList?.toggle("hidden", true);
    });
  }

  markAsDirty() {
    this.dirty = true;
  }

  select(event) {
    const target = event.target;
    event.preventDefault();
    this.resetQueryInput();
  }

  selectedMemberIds() {
    const recipientTags = this.addressBookTarget.querySelectorAll(".recipient");
    const memberIds = Array.from(recipientTags).map((tag) => { return tag.dataset.recipientId; });
    return memberIds;
  }

  resetQueryInput() {
    this.queryInputTarget.value = "";
  }

  toggleRecipientList(event) {
    this.addressBookTarget.classList.toggle("hidden");
    event.preventDefault();
  }

  toggleFormattingToolbar (event) {
    this.element.classList.toggle("formatting-active");
    event.preventDefault();
  }

  uploadFiles() {
    const files = this.fileInputTarget.click();
  }

  validate() {
    var valid = this.subjectTextBoxTarget.value.length > 0;
    // valid = valid && this.bodyTextAreaTarget?.value?.length > 0;
    const recipientCount = this.addressBookTarget.querySelectorAll(".recipient").length
    valid = valid && recipientCount > 0;

    this.sendMessageButtonTarget.disabled = !valid;
    this.sendLaterButtonTarget.disabled   = !valid;
    this.sendPreviewButtonTarget.disabled = !valid;
    // this.queryInputTarget.placeholder = recipientCount > 0 ? "" : "Search for people, events, or groups...";
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

  removeAttachmentCandidate(event) {
    var elem = event.target.closest(".attachment-candidate");
    elem.remove();
  }
}
