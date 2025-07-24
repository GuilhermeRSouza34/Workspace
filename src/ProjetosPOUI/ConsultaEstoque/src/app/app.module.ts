import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { PoModule } from '@po-ui/ng-components';
import { PoTemplatesModule } from '@po-ui/ng-templates';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ConsultaEstoqueComponent } from './consulta-estoque/consulta-estoque.component';
import { EstoqueService } from './services/estoque.service';

@NgModule({
  declarations: [
    AppComponent,
    ConsultaEstoqueComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    AppRoutingModule,
    PoModule,
    PoTemplatesModule
  ],
  providers: [
    EstoqueService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
