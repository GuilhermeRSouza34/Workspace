import { OnInit } from '@angular/core';
import { PoGaugeCoordinates } from '../../interfaces/po-gauge-coordinates.interface';
import * as i0 from "@angular/core";
export declare class PoGaugePathComponent implements OnInit {
    baseCoordinates: PoGaugeCoordinates;
    rangesCoordinates: Array<PoGaugeCoordinates>;
    constructor();
    ngOnInit(): void;
    trackBy(index: any): any;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoGaugePathComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoGaugePathComponent, "[po-gauge-path]", never, { "baseCoordinates": "p-base-coordinates"; "rangesCoordinates": "p-ranges-coordinates"; }, {}, never, never, false>;
}
