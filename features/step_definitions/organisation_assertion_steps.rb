Then(/^I should see links to all this organisation's sites and homepages$/) do
  @organisation.sites.each do |site|
    expect(page).to have_link('', href: site_mappings_path(site.abbr))
    expect(page).to have_link('', href: site.homepage)
  end
end

Then(/^I should see that this organisation is an executive non-departmental public body of its parent$/) do
  expect(page).to have_content('is an executive non-departmental public body of')
  expect(page).to have_link('', href: organisation_path(@organisation.parent))
end

Then(/^I should see a link to the organisation (.*)$/) do |title|
  organisation = Organisation.find_by_title(title)
  expect(page).to have_link('', href: organisation_path(organisation))
end
