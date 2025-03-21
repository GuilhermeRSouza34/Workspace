import { AfterViewInit, ElementRef, EventEmitter, Renderer2 } from '@angular/core';
import { PoUploadLiterals } from '../../interfaces/po-upload-literals.interface';
import * as i0 from "@angular/core";
export declare class PoUploadDragDropAreaOverlayComponent implements AfterViewInit {
    private renderer;
    DragDropAreaFixed: ElementRef;
    directoryCompatible: boolean;
    disabled: boolean;
    literals: PoUploadLiterals;
    target: ElementRef;
    areaElement: EventEmitter<any>;
    constructor(renderer: Renderer2);
    ngAfterViewInit(): void;
    private setPosition;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoUploadDragDropAreaOverlayComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoUploadDragDropAreaOverlayComponent, "po-upload-drag-drop-area-overlay", never, { "directoryCompatible": "p-directory-compatible"; "disabled": "p-disabled"; "literals": "p-literals"; "target": "p-target"; }, { "areaElement": "p-area-element"; }, never, never, false>;
}
