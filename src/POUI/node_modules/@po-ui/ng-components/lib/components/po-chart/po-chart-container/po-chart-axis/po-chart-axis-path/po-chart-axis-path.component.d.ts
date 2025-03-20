import { PoChartPathCoordinates } from '../../../interfaces/po-chart-path-coordinates.interface';
import * as i0 from "@angular/core";
export declare class PoChartAxisPathComponent {
    axisXCoordinates: Array<PoChartPathCoordinates>;
    axisYCoordinates: Array<PoChartPathCoordinates>;
    constructor();
    trackBy(index: any): any;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoChartAxisPathComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoChartAxisPathComponent, "[po-chart-axis-path]", never, { "axisXCoordinates": "p-axis-x-coordinates"; "axisYCoordinates": "p-axis-y-coordinates"; }, {}, never, never, false>;
}
