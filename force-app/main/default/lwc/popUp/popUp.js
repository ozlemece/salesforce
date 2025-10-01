import { LightningElement, api, track } from 'lwc';
import MRM_PROMPT_MESSAGE from '@salesforce/label/c.MRMPromptMessage';

export default class MyModalComponent extends LightningElement {
    @track isModalPopup = true; // Controls modal visibility
    @track renderedOnce = false; // Controls if component has rendered once
    promptMessage = MRM_PROMPT_MESSAGE; // Using a custom label

    connectedCallback() {
        // Retrieve the community name or site ID (similar to Aura's doInit)
        this.communityName = this.getCommunityName();
    }

    renderedCallback() {
        // Trap focus for 508 compliance, similar to Aura's onRender handler
        if (!this.renderedOnce) {
            this.renderedOnce = true;
            this.setFocusOnButton();
            this.setupKeyUpListener();
        }
    }

    // Handles the "Agree" button click to close the modal
    handleAgreement() {
        this.isModalPopup = false;
    }

    // Sets focus on the "Agree" button when modal is displayed
    setFocusOnButton() {
        const agreeButton = this.template.querySelector('button');
        if (agreeButton) {
            agreeButton.focus();
        }
    }

    // Adds a keyup event listener to focus on the "Agree" button if not in focus
    setupKeyUpListener() {
        window.addEventListener('keyup', (event) => {
            if (event.keyCode === 9 && this.isModalPopup) { // Tab key
                const activeElement = this.template.activeElement;
                const agreeButton = this.template.querySelector('button');
                if (activeElement !== agreeButton) {
                    agreeButton.focus();
                }
            }
        });
    }

    // Placeholder for community name retrieval (similar to `Site.getSiteId()` in Aura)
    getCommunityName() {
        // Implement community or site retrieval logic as per requirements
        return 'Default Community';
    }
}
