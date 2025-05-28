import { ElementRef } from '@angular/core';
import * as i0 from "@angular/core";
export declare class PoGaugeDescriptionComponent {
    description: string;
    hasRanges: boolean;
    descriptionWidth: number;
    value: number;
    descriptionText: ElementRef;
    tooltip: string;
    get isValidValue(): number | boolean;
    verifyIfHasEllipsis(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoGaugeDescriptionComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoGaugeDescriptionComponent, "po-gauge-description", never, { "description": "p-description"; "hasRanges": "p-has-ranges"; "descriptionWidth": "p-description-width"; "value": "p-value"; }, {}, never, never, false>;
}
