import { LightningElement, api, wire, track } from 'lwc';
import getSubjects from '@salesforce/apex/OPC_SubjectController.getSubjects';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class SubjectTableWithDetails extends NavigationMixin(LightningElement) {
    @api recordId; // Case Id if on Case page
    @api caseId;   // Optional design-time Case Id

    @track rows = [];
    selectedId;
    showNewModal = false;

    wiredResult; // hold @wire result for refresh

    // 5 table columns
    columns = [
        {
            label: 'Subject',
            fieldName: 'recordUrl',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'openSubject',
                variant: 'base'
            },
            wrapText: true
        },
        { label: 'Division', fieldName: 'Division__c', type: 'text' },
        { label: 'Grade', fieldName: 'Grade__c', type: 'text' },
        { label: 'Corrective Action Taken', fieldName: 'Corrective_Action_Taken__c', type: 'text' },
        { label: 'Action Taken', fieldName: 'Action_Taken__c', type: 'text' }
    ];

    get effectiveCaseId() {
        return this.caseId || this.recordId || null;
    }

    @wire(getSubjects, { caseId: '$effectiveCaseId' })
    wiredSubjects(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.rows = data.map(row => ({ ...row, recordUrl: 'open' }));
        } else if (error) {
            this.rows = [];
            this.toast('Error loading subjects', this.flattenError(error), 'error');
        }
    }

    // --- Table selection / actions ---
    handleRowSelection(evt) {
        const selected = evt.detail.selectedRows?.[0];
        this.selectedId = selected ? selected.Id : null;
    }

    handleRowAction(evt) {
        const { action, row } = evt.detail || {};
        if (action?.name === 'openSubject' && row?.Id) {
            this.selectedId = row.Id;
            const dt = this.template.querySelector('lightning-datatable');
            if (dt) dt.selectedRows = [row.Id];
        }
    }

// --- New Subject redirect to standard New Record page ---
openNewModal = () => {
    if (!this.effectiveCaseId) {
        this.toast(
            'Case required',
            'Place this on a Case page or set the Case Id in App Builder.',
            'warning'
        );
        return;
    }

    this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Subject__c',
            actionName: 'new'
        },
        state: {
            // Pre-populate Case__c lookup
            defaultFieldValues: `Case__c=${this.effectiveCaseId}`
        }
    });
};


    closeNewModal = () => { this.showNewModal = false; };

    handleNewSuccess = (evt) => {
        this.showNewModal = false;
        const newId = evt.detail.id;
        this.toast('Subject created', 'A new Subject record was created.', 'success');
        this.refreshList().then(() => {
            this.selectedId = newId;
            const dt = this.template.querySelector('lightning-datatable');
            if (dt) dt.selectedRows = [newId];
        });
    };

    handleNewError = (evt) => {
        this.toast('Create failed', this.flattenError(evt.detail), 'error');
    };

    // --- Detail form save ---
    submitForm = () => {
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) form.submit();
    };

    handleSaveSuccess() {
        this.toast('Subject saved', 'Changes were saved successfully.', 'success');
        this.refreshList();
    }

    handleFormError(evt) {
        this.toast('Save failed', this.flattenError(evt.detail), 'error');
    }

    async refreshList() {
        if (this.wiredResult) {
            await refreshApex(this.wiredResult);
        }
    }

    // --- Nav + helpers ---
    navToRecord = () => {
        if (!this.selectedId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedId,
                actionName: 'view',
                objectApiName: 'Subject__c'
            }
        });
    };

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    flattenError(error) {
        if (Array.isArray(error?.body)) return error.body.map(e => e.message).join(', ');
        if (typeof error?.body?.message === 'string') return error.body.message;
        if (typeof error === 'string') return error;
        return 'Unexpected error';
    }
}
