import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <po-page-default
      p-title="Meu Primeiro Projeto POUI"
      [p-breadcrumb]="breadcrumb">
      
      <form #formExample="ngForm">
        <div class="po-row">
          <po-input
            class="po-md-6"
            name="name"
            [(ngModel)]="name"
            p-label="Nome"
            p-required>
          </po-input>

          <po-number
            class="po-md-6"
            name="code"
            [(ngModel)]="code"
            p-label="Código"
            p-required>
          </po-number>
        </div>

        <div class="po-row">
          <po-button
            class="po-md-3"
            p-label="Salvar"
            p-type="primary"
            [p-disabled]="formExample.invalid"
            (p-click)="save()">
          </po-button>
        </div>
      </form>

    </po-page-default>
  `
})
export class AppComponent {
  name: string = '';
  code: number = 0;
  
  breadcrumb = {
    items: [
      { label: 'Home', link: '/' },
      { label: 'Cadastro', link: '/cadastro' }
    ]
  };

  save() {
    // Aqui implementaremos a integração com o backend ADVPL
    console.log('Dados salvos:', { name: this.name, code: this.code });
  }
}