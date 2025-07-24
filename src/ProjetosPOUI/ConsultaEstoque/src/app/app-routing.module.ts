import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ConsultaEstoqueComponent } from './consulta-estoque/consulta-estoque.component';

const routes: Routes = [
  { path: '', redirectTo: '/consulta-estoque', pathMatch: 'full' },
  { path: 'consulta-estoque', component: ConsultaEstoqueComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
