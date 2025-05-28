import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente responsável por exibir os círculos dos *steps*.
 */
export declare class PoStepperCircleComponent {
    content: any;
    icons: boolean;
    size: number;
    status: string;
    get isActive(): boolean;
    get isDefault(): boolean;
    get isDisabled(): boolean;
    get isDone(): boolean;
    get isError(): boolean;
    get isLargeStep(): boolean;
    get isMediumStep(): boolean;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoStepperCircleComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoStepperCircleComponent, "po-stepper-circle", never, { "content": "p-content"; "icons": "p-icons"; "size": "p-size"; "status": "p-status"; }, {}, never, never, false>;
}
