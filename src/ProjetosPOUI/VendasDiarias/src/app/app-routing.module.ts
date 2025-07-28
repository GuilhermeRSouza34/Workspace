import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { VendasDiariasComponent } from './vendas-diarias/vendas-diarias.component';

const routes: Routes = [
  { path: '', redirectTo: '/vendas-diarias', pathMatch: 'full' },
  { path: 'vendas-diarias', component: VendasDiariasComponent },
  { path: '**', redirectTo: '/vendas-diarias' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
