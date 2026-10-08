RSpec.describe MathematicalTreeprocessor do
  it 'replaces a latexmath block with a PNG image written to imagesdir' do
    doc = load_doc <<~'EOS'
      [latexmath]
      ++++
      x^2
      ++++
    EOS

    expect(doc.find_by context: :stem).to be_empty
    images = doc.find_by context: :image
    expect(images.size).to eq 1
    target = images[0].attr 'target'
    expect(target).to match(/\Astem-\h{32}\.png\z/)
    expect(generated_files).to eq [%(images/#{target})]
  end

  it 'writes SVG images when mathematical-format is svg' do
    doc = load_doc <<~'EOS', 'mathematical-format' => 'svg'
      [latexmath]
      ++++
      x^2
      ++++
    EOS

    images = doc.find_by context: :image
    expect(images.size).to eq 1
    target = images[0].attr 'target'
    expect(target).to match(/\Astem-\h{32}\.svg\z/)
    expect(generated_files).to eq [%(images/#{target})]
  end

  it 'keeps the block id so cross references resolve' do
    doc = load_doc <<~'EOS'
      [latexmath#eq-heat,reftext=eq. ({counter:eqs})]
      ++++
      E = mc^2
      ++++

      See <<eq-heat>>.
    EOS

    images = doc.find_by context: :image
    expect(images.size).to eq 1
    expect(images[0].id).to eq 'eq-heat'
    html = doc.convert
    expect(html).to include 'id="eq-heat"'
    expect(html).to include '<a href="#eq-heat">eq. (1)</a>'
  end

  it 'replaces an inline latexmath macro with an inline image' do
    doc = load_doc 'Area is latexmath:[\pi r^2].'

    source = (doc.find_by context: :paragraph)[0].source
    expect(source).to match(/\AArea is image:stem-\h{32}\.png\[width=\d+,height=\d+\]\.\z/)
    target = source[/stem-\h{32}\.png/]
    expect(generated_files).to eq [%(images/#{target})]
  end

  it 'leaves the document untouched when stem is not set' do
    doc = ::Asciidoctor.load 'Area is latexmath:[\pi r^2].', safe: :safe, base_dir: tmp_dir

    expect((doc.find_by context: :paragraph)[0].source).to eq 'Area is latexmath:[\pi r^2].'
    expect(generated_files).to be_empty
  end
end
