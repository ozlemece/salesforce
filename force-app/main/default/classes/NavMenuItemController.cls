public with sharing class NavigationMenuItemController { 

    /**
     * Retrieves navigation menu items based on specified parameters.
     *
     * @param navigationLinkSetMasterLabel The menu name (NavigationLinkSet.MasterLabel)
     * @param publishStatus The publication status of the menu items (Live or Draft)
     * @param addHomeMenuItem If true, includes the Home menu item in the data
     * @param includeImageUrl If true, includes image URLs for menu items; relevant permissions required for Document object (for CustomBrandAsset)
     * @return A list of ConnectApi.NavigationMenuItem representing the navigation menu items
     */
    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.NavigationMenuItem> getNavigationMenuItems(String navigationLinkSetMasterLabel, String publishStatus, Boolean addHomeMenuItem, Boolean includeImageUrl) {
        // List to store retrieved navigation menu items
        List<ConnectApi.NavigationMenuItem> items = new List<ConnectApi.NavigationMenuItem>();

        try {
            // Validate that required parameter is not null
            System.assert(navigationLinkSetMasterLabel != null);
            
            // Retrieve the Developer Name of the navigation link set based on its master label
            String navigationLinkSetDeveloperName = getNavigationLinkSetDeveloperName(navigationLinkSetMasterLabel);

            // Validate publish status is provided and is either "Live" or "Draft"
            System.assert(publishStatus != null);
            System.assert(publishStatus.equalsIgnoreCase(ConnectApi.PublishStatus.Live.name()) || publishStatus.equalsIgnoreCase(ConnectApi.PublishStatus.Draft.name()));

            // Map publishStatus string to ConnectApi.PublishStatus enum (Live or Draft)
            ConnectApi.PublishStatus publishStatusEnum;
            if (publishStatus.equalsIgnoreCase(ConnectApi.PublishStatus.Draft.name())) {
                publishStatusEnum = ConnectApi.PublishStatus.Draft;
            } else {
                publishStatusEnum = ConnectApi.PublishStatus.Live;
            }

            // Define menu item types to skip (Event and SystemLink types not supported in custom component nav menus)
            List<ConnectApi.NavigationMenuItemType> menuItemsToSkip = new List<ConnectApi.NavigationMenuItemType>{
                ConnectApi.NavigationMenuItemType.Event, 
                ConnectApi.NavigationMenuItemType.SystemLink 
            };

            // Variable to hold network ID for the current community
            String networkId;
            String navigationLinkSetId = null; // Not required here; keeping null

            // Get network ID based on the current context, or set a specific value during testing
            if (!Test.isRunningTest()) {
                networkId = Network.getNetworkId(); // Retrieves network ID in non-test context
            } else {
                networkId = [SELECT Id FROM Network WHERE Name = 'MRM'].Id; // Hardcoded for testing purposes
            }
            System.assert(networkId != null); // Ensure network ID is retrieved

            // Retrieve the navigation menu items using ConnectApi
            ConnectApi.NavigationMenuItemCollection menu = ConnectApi.NavigationMenu.getCommunityNavigationMenu(
                networkId, 
                navigationLinkSetId, 
                navigationLinkSetDeveloperName, 
                publishStatusEnum, 
                includeImageUrl, 
                addHomeMenuItem, 
                menuItemsToSkip
            );
            
            // Assign retrieved menu items to the items list
            items = menu.menuItems;

        } catch (Exception e) {
            // Catch and log any errors encountered during execution
            System.debug('An error occurred: ' + e.getMessage());
        }

        // Return the list of navigation menu items
        return items;
    }

    /**
     * Helper method to retrieve the Developer Name of a NavigationLinkSet based on its Master Label and current Network ID.
     *
     * @param navigationLinkSetMasterLabel The Master Label of the navigation link set
     * @return The Developer Name of the specified navigation link set
     */
    @TestVisible private static String getNavigationLinkSetDeveloperName(String navigationLinkSetMasterLabel) {
        // Variable to store network ID
        String networkId;
        String developerName = null; // Placeholder for Developer Name to return

        try {
            // Get the network ID based on the context or a specific value for testing
            if (!Test.isRunningTest()) {networkId = Network.getNetworkId(); // Get network ID in non-test context
            } else {
                networkId = [SELECT Id FROM Network WHERE Name = 'MRM'].Id; // Hardcoded for test context
            }
            System.assert(networkId != null); // Ensure network ID is retrieved

            // Query the NavigationLinkSet for the specified master label and network ID
            List<NavigationLinkSet> navigationLinkSets = [SELECT DeveloperName, Id, MasterLabel, NetworkId
                                                          FROM NavigationLinkSet 
                                                          WHERE NetworkId = :networkId 
                                                          AND MasterLabel = :navigationLinkSetMasterLabel WITH SECURITY_ENFORCED
                                                          LIMIT 1];
            
            // Assert that exactly one NavigationLinkSet is found
            System.assert(navigationLinkSets.size() == 1);
            NavigationLinkSet navigationLinkSet = navigationLinkSets.get(0); // Retrieve the single result

            // Assign Developer Name to the return variable
            developerName = navigationLinkSet.DeveloperName;

        } catch (Exception e) {
            // Log any errors that occur during the process
            System.debug('An error occurred in getNavigationLinkSetDeveloperName: ' + e.getMessage());
        }

        // Return the Developer Name of the NavigationLinkSet
        return developerName;
    }

}
