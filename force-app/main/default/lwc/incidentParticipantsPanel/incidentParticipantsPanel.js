import { LightningElement, api, wire, track } from 'lwc';
import getParticipantsWithAllegations from '@salesforce/apex/IncidentParticipantsController.getParticipantsWithAllegations';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IncidentParticipantsPanel extends LightningElement {
  @api recordId; // Case Id
  @track role = 'Subject'; // default view per your requirement
  @track filter = '';
  wiredResult;
  participants = [];
  error;

  roleOptions = [
    { label: 'Subject', value: 'Subject' },
    { label: 'Complainant', value: 'Complainant' },
    { label: 'Witness', value: 'Witness' }
  ];

  allegationColumns = [
    { label: 'Type', fieldName: 'type', type: 'text', wrapText: true },
    { label: 'Subtype', fieldName: 'subType', type: 'text', wrapText: true },
    { label: 'Substantiated', fieldName: 'substantiated', type: 'boolean' },
    { label: 'Date Occurred', fieldName: 'dateOccurred', type: 'date' },
    { label: 'Corrective Action', fieldName: 'correctiveAction', type: 'text', wrapText: true },
    { label: 'Action Taken', fieldName: 'actionTaken', type: 'text', wrapText: true },
    { label: 'Notes', fieldName: 'notes', type: 'text', wrapText: true }
  ];

  @wire(getParticipantsWithAllegations, { caseId: '$recordId', roleFilter: '$role' })
  wiredParticipants(result) {
    this.wiredResult = result;
    const { data, error } = result;
    if (data) {
      this.participants = data.map(p => ({ ...p, nonFdicLabel: p.nonFdic ? 'Yes' : 'No' }));
      this.error = undefined;
    } else {
      this.error = error;
      this.participants = [];
    }
  }

  get errorMessage() {
    return this.error?.body?.message || this.error?.message || 'Unknown error';
  }

  get participantsToShow() {
    if (!this.participants?.length) return null;
    const f = (this.filter || '').toLowerCase();
    if (!f) return this.participants;
    return this.participants.filter(p =>
      (p.name || '').toLowerCase().includes(f) ||
      (p.division || '').toLowerCase().includes(f) ||
      (p.grade || '').toLowerCase().includes(f)
    );
  }

  handleRoleChange(e) { this.role = e.detail.value; }
  handleFilter(e)     { this.filter = e.target.value; }

  async refresh() {
    await refreshApex(this.wiredResult);
    this.dispatchEvent(new ShowToastEvent({ title: 'Refreshed', message: 'Data reloaded', variant: 'success' }));
  }

  newAllegation(e) {
    const participantId = e.currentTarget.dataset.participantId;
    this.dispatchEvent(new CustomEvent('newallegation', { detail: { participantId } }));
    // Hook to your quick action/flow/modal create as needed.
  }
}
