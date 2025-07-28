import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

// PO-UI Modules
import { PoModule } from '@po-ui/ng-components';
import { PoTemplatesModule } from '@po-ui/ng-templates';

// App Components
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { VendasDiariasComponent } from './vendas-diarias/vendas-diarias.component';

@NgModule({
  declarations: [
    AppComponent,
    VendasDiariasComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    PoModule,
    PoTemplatesModule
  ],
  providers: [
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
