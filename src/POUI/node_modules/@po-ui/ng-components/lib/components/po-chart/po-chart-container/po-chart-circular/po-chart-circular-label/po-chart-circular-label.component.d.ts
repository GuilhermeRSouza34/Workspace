import { ChangeDetectorRef, ElementRef, Renderer2 } from '@angular/core';
import { PoChartLabelCoordinates } from '../../../interfaces/po-chart-label-coordinates.interface';
import * as i0 from "@angular/core";
export declare class PoChartCircularLabelComponent {
    private changeDetection;
    private renderer;
    serie: PoChartLabelCoordinates;
    showLabel: boolean;
    svgLabel: ElementRef;
    constructor(changeDetection: ChangeDetectorRef, renderer: Renderer2);
    applyCoordinates(coordinates: PoChartLabelCoordinates): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoChartCircularLabelComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoChartCircularLabelComponent, "[po-chart-circular-label]", never, { "serie": "p-serie"; "showLabel": "p-show-label"; }, {}, never, never, false>;
}
