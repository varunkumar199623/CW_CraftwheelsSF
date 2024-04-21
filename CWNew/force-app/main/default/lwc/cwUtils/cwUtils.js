/**
 * @description A utility function to display toast messages in Lightning Web Components.
 * @Author: Varun Kumar Sirisilla
 */

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

function showToast(page, title, message, variant, mode) {
    // Create a new ShowToastEvent
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });

    // Dispatch the event to show the toast
    page.dispatchEvent(event);
}

export {
    showToast
}