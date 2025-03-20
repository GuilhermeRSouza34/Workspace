import { EventEmitter } from '@angular/core';
import { PoStepperOrientation } from '../enums/po-stepper-orientation.enum';
import { PoStepperStatus } from '../enums/po-stepper-status.enum';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente que representa um *step* contendo as ligações das laterais (`po-stepper-step-bar`) e a label.
 */
export declare class PoStepperStepComponent {
    circleContent: any;
    orientation: PoStepperOrientation;
    nextStatus: any;
    activated: EventEmitter<any>;
    click: EventEmitter<any>;
    enter: EventEmitter<any>;
    readonly literals: any;
    private _label;
    private _status;
    private _stepIcons?;
    private _stepSize;
    set label(value: string);
    get label(): string;
    set status(value: PoStepperStatus);
    get status(): PoStepperStatus;
    set stepIcons(stepIcons: boolean);
    get stepIcons(): boolean;
    set stepSize(value: number);
    get stepSize(): number;
    get halfStepSize(): number;
    get isVerticalOrientation(): boolean;
    get marginHorizontalBar(): number;
    getStatusClass(status: string): string;
    onClick(): void;
    onEnter(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoStepperStepComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoStepperStepComponent, "po-stepper-step", never, { "circleContent": "p-circle-content"; "orientation": "p-orientation"; "nextStatus": "p-next-status"; "label": "p-label"; "status": "p-status"; "stepIcons": "p-step-icons"; "stepSize": "p-step-size"; }, { "activated": "p-activated"; "click": "p-click"; "enter": "p-enter"; }, never, never, false>;
}
