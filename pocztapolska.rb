#!/usr/bin/ruby
# -*- coding: utf-8 -*-
##
# pocztapolska.rb - program sprawdzający przesyłki zgodnie z numerami przy użyciu API Poczty Polskiej
# Copyright (C) 2014 Jakub Skrzypnik <jot.skrzyp@gmail.com>
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
##

require 'savon'

# Tablica asocjacyjna, podajesz kolejne numery przesyłek
package_numbers = { 
  adam: '00000000000000000000',
  ewa: '00000000000000000000'
  }

# JebaÄ API Poczty Polskiej, serio.
client = Savon.client(wsdl: "https://tt.poczta-polska.pl/Sledzenie/services/Sledzenie?wsdl", wsse_auth: ["sledzeniepp", "PPSA"])

package_numbers.each_value { |number|
  # Tu powinna być klasa Package, ale mi się nie chciało.
  response = client.call(:sprawdz_przesylke_pl, message: { numer: number })
  package_data = response.body[:sprawdz_przesylke_pl_response][:return][:dane_przesylki]
  origin_office_data = package_data[:urzad_nadania][:dane_szczegolowe]
  destination_office_data = package_data[:urzad_przezn][:dane_szczegolowe]
  package_events = package_data[:zdarzenia][:zdarzenie]
  puts %{ 
Nick: #{package_numbers.key(number).to_s}
Numer przesyĹki: #{package_data[:numer]}
Data nadania: #{package_data[:data_nadania]}
Rodzaj przesyĹki: #{package_data[:rodz_przes]}
Masa: #{package_data[:masa]}kg
Urząd nadania: #{origin_office_data[:miejscowosc]}
               #{origin_office_data[:ulica]} #{destination_office_data[:nr_domu]}
               #{origin_office_data[:pna]} }
  # Nie zawsze jest podawany urząd przeznaczenia
  if destination_office_data[:dl_geogr] != "0.0" then
      puts %{
Urząd przeznaczenia: #{destination_office_data[:miejscowosc]}
                     #{destination_office_data[:ulica]} #{destination_office_data[:nr_domu]}
                     #{destination_office_data[:pna]} }
  end
  puts "Status przesyĹki:"
  # Zapytanie zwraca tablicę zdarzeń, jeśli było więcej, niż jedno, inaczej zwraca tylko wartość 
  if package_events.kind_of?(Array) == true then
    package_events.each { |e|
      puts %{ #{e[:czas]} #{e[:nazwa]} #{e[:jednostka][:nazwa]}}
    }
  else
    puts %{ #{package_events[:czas]} #{package_events[:nazwa]} #{package_events[:jednostka][:nazwa]}}
  end
}
