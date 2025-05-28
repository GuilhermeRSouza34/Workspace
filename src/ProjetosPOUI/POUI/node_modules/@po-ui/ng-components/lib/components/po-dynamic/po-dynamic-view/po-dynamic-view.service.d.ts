import { HttpClient } from '@angular/common/http';
import { PoDynamicViewField } from '../po-dynamic-view/po-dynamic-view-field.interface';
import * as i0 from "@angular/core";
export declare class PoDynamicViewService {
    private http;
    constructor(http: HttpClient);
    onLoad(url: string, value: any): Promise<{
        value?: any;
        fields?: Array<PoDynamicViewField>;
    }>;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoDynamicViewService, never>;
    static ɵprov: i0.ɵɵInjectableDeclaration<PoDynamicViewService>;
}
