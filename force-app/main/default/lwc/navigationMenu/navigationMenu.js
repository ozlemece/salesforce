import { LightningElement, wire, api, track } from 'lwc';
import getNavigationMenuItems from '@salesforce/apex/NavigationMenuItemController.getNavigationMenuItems';

export default class NavigationMenu extends LightningElement {
    // Public properties that can be set when using this component
    @api navigationLinkSetMasterLabel;
    @api publishStatus = 'Live';
    @api addHomeMenuItem = false;
    @api includeImageUrl = false;

    @track menuItems;
    @track error;

    // Call the Apex method with parameters to retrieve the navigation menu items
    @wire(getNavigationMenuItems, {
        navigationLinkSetMasterLabel: '$navigationLinkSetMasterLabel',
        publishStatus: '$publishStatus',
        addHomeMenuItem: '$addHomeMenuItem',
        includeImageUrl: '$includeImageUrl'
    })
    wiredMenuItems({ error, data }) {
        if (data) {
            // Assign the retrieved data to the menuItems variable
            this.menuItems = data;
            this.error = undefined;
        } else if (error) {
            // Handle any errors that occur during the Apex call
            this.error = error.body.message;
            this.menuItems = undefined;
        }
    }
}
