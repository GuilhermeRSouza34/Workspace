import { EventEmitter } from '@angular/core';
import * as i0 from "@angular/core";
export declare class PoCalendarHeaderComponent {
    hidePrevious: boolean;
    hideNext: boolean;
    previous: EventEmitter<void>;
    next: EventEmitter<void>;
    constructor();
    static ɵfac: i0.ɵɵFactoryDeclaration<PoCalendarHeaderComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoCalendarHeaderComponent, "po-calendar-header", never, { "hidePrevious": "p-hide-previous"; "hideNext": "p-hide-next"; }, { "previous": "p-previous"; "next": "p-next"; }, never, ["*"], false>;
}
