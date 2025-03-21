import * as i0 from "@angular/core";
import * as i1 from "./po-accordion.component";
import * as i2 from "./po-accordion-item-body/po-accordion-item-body.component";
import * as i3 from "./po-accordion-item/po-accordion-item.component";
import * as i4 from "./po-accordion-item-header/po-accordion-item-header.component";
import * as i5 from "@angular/common";
/**
 * @description
 *
 * Módulo do componente `po-accordion`.
 *
 * > Para o correto funcionamento do componente `po-accordion`, deve ser importado o módulo `BrowserAnimationsModule` no
 * > módulo principal da sua aplicação.
 *
 * Módulo da aplicação:
 * ```
 * import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
 * import { PoModule } from '@po-ui/ng-components';
 * ...
 *
 * @NgModule({
 *   imports: [
 *     BrowserModule,
 *     BrowserAnimationsModule,
 *     ...
 *     PoModule
 *   ],
 *   declarations: [
 *     AppComponent,
 *     ...
 *   ],
 *   providers: [],
 *   bootstrap: [AppComponent]
 * })
 * export class AppModule { }
 * ```
 */
export declare class PoAccordionModule {
    static ɵfac: i0.ɵɵFactoryDeclaration<PoAccordionModule, never>;
    static ɵmod: i0.ɵɵNgModuleDeclaration<PoAccordionModule, [typeof i1.PoAccordionComponent, typeof i2.PoAccordionItemBodyComponent, typeof i3.PoAccordionItemComponent, typeof i4.PoAccordionItemHeaderComponent], [typeof i5.CommonModule], [typeof i1.PoAccordionComponent, typeof i3.PoAccordionItemComponent]>;
    static ɵinj: i0.ɵɵInjectorDeclaration<PoAccordionModule>;
}
