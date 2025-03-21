import { ChangeDetectorRef, ElementRef, EventEmitter } from '@angular/core';
import { PoUploadDragDropAreaComponent } from './po-upload-drag-drop-area/po-upload-drag-drop-area.component';
import { PoUploadLiterals } from '../interfaces/po-upload-literals.interface';
import * as i0 from "@angular/core";
export declare class PoUploadDragDropComponent {
    private changeDetector;
    dragDropOverlayElement: ElementRef;
    dragDropAreaComponent: PoUploadDragDropAreaComponent;
    directoryCompatible: boolean;
    disabled: boolean;
    literals: PoUploadLiterals;
    fileChange: EventEmitter<any>;
    selectFiles: EventEmitter<any>;
    areaElement: HTMLElement;
    isDragOver: boolean;
    private _dragDropHeight?;
    set dragDropHeight(value: number);
    get dragDropHeight(): number;
    constructor(changeDetector: ChangeDetectorRef);
    focus(): void;
    onAreaElement(element: HTMLElement): void;
    onDragLeave(): void;
    onDragOver(): void;
    onFileChange(files: any): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoUploadDragDropComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoUploadDragDropComponent, "po-upload-drag-drop", never, { "directoryCompatible": "p-directory-compatible"; "disabled": "p-disabled"; "literals": "p-literals"; "dragDropHeight": "p-drag-drop-height"; }, { "fileChange": "p-file-change"; "selectFiles": "p-select-files"; }, never, never, false>;
}
