import { LightningElement, api, wire } from 'lwc';
import getLoginSSOMRM from '@salesforce/apex/DRRClaimsPortalController.loginSSOMRM';
import loginGovLogo from '@salesforce/resourceUrl/login_gov_logo';

export default class DrrClaimsPortal extends LightningElement {
    @api samlLoginUrl;

    loginGovLogoUrl = loginGovLogo;

    connectedCallback() {
        this.getLoginUrl();
    }

    getLoginUrl() {
        getLoginSSOMRM()
            .then(result => {
                this.samlLoginUrl = result;
            })
            .catch(error => {
                console.error('Error fetching SSO login URL:', error);
            });
    }

    handleSSOLogin() {
        window.location.href = this.samlLoginUrl;
    }
}
