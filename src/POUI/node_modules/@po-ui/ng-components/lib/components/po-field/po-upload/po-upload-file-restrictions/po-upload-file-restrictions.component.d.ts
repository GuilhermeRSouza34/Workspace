import { ChangeDetectorRef, OnInit } from '@angular/core';
import { PoLanguageService } from '../../../../services/po-language/po-language.service';
import * as i0 from "@angular/core";
export declare class PoUploadFileRestrictionsComponent implements OnInit {
    private changeDetector;
    maxFiles: number;
    literals: any;
    private _allowedExtensions;
    private _maxFileSize;
    private _minFileSize;
    private language;
    set allowedExtensions(value: string);
    get allowedExtensions(): string;
    set maxFileSize(value: string);
    get maxFileSize(): string;
    set minFileSize(value: string);
    get minFileSize(): string;
    constructor(changeDetector: ChangeDetectorRef, languageService: PoLanguageService);
    ngOnInit(): void;
    private formatAllowedExtensions;
    private setLiterals;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoUploadFileRestrictionsComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoUploadFileRestrictionsComponent, "po-upload-file-restrictions", never, { "maxFiles": "p-max-files"; "allowedExtensions": "p-allowed-extensions"; "maxFileSize": "p-max-file-size"; "minFileSize": "p-min-file-size"; }, {}, never, never, false>;
}
