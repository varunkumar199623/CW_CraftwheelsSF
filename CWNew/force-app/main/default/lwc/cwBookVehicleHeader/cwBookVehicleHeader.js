/**
 * @description Lightning Web Component to display the Craftwheels logo in the header.
 * @Author: Varun Kumar Sirisilla
 */

import { LightningElement } from 'lwc';
import CW_CraftwheelsLogo from '@salesforce/resourceUrl/CW_CraftwheelsLogo';

export default class CwBookVehicleHeader extends LightningElement {
    // Property to store the URL of the Craftwheels logo
    craftwheelsLogo = CW_CraftwheelsLogo;
}