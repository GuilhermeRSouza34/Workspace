import { AfterViewInit, ChangeDetectorRef, ElementRef } from '@angular/core';
import * as i0 from "@angular/core";
export declare class PoChartPathComponent implements AfterViewInit {
    private changeDetector;
    isActive: boolean;
    chartLine: boolean;
    coordinates: string;
    chartPath: ElementRef;
    pathWidth: number;
    private _animate;
    private _color;
    set color(value: string);
    get color(): string;
    set animate(value: boolean);
    get animate(): boolean;
    constructor(changeDetector: ChangeDetectorRef);
    ngAfterViewInit(): void;
    private pathAnimation;
    private preventsAnimatingAgain;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoChartPathComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoChartPathComponent, "[po-chart-path]", never, { "isActive": "p-is-active"; "chartLine": "p-chart-line"; "coordinates": "p-coordinates"; "color": "p-color"; "animate": "p-animate"; }, {}, never, never, false>;
}
