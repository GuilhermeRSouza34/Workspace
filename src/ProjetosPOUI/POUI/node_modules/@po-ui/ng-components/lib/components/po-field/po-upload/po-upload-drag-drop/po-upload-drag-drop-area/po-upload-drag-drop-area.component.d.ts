import { ElementRef, EventEmitter } from '@angular/core';
import { PoUploadLiterals } from '../../interfaces/po-upload-literals.interface';
import * as i0 from "@angular/core";
export declare class PoUploadDragDropAreaComponent {
    elementRef: ElementRef;
    directoryCompatible: boolean;
    disabled: boolean;
    height: number;
    literals: PoUploadLiterals;
    overlay: boolean;
    selectFiles: EventEmitter<any>;
    selectFilesLinkElement: ElementRef;
    constructor(elementRef: ElementRef);
    focus(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoUploadDragDropAreaComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoUploadDragDropAreaComponent, "po-upload-drag-drop-area", never, { "directoryCompatible": "p-directory-compatible"; "disabled": "p-disabled"; "height": "p-height"; "literals": "p-literals"; "overlay": "p-overlay"; }, { "selectFiles": "p-select-files"; }, never, never, false>;
}
