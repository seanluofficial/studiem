-- 003_seed_apchem.sql
-- Seeds source_cards and question_variants from content/apchem/unit*.json
-- All cards seeded with reviewed=true so they are served in battles
-- Only mc_static cards get a question_variant record (mc_numeric/fr need variant generation)

DO $$
DECLARE
  v_card_id UUID;
BEGIN

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_static',
    'easy',
    ARRAY['mole_concept','avogadro'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the value of Avogadro''s number?","options":["6.022 × 10²³ mol⁻¹","6.022 × 10²⁰ mol⁻¹","6.022 × 10²⁶ mol⁻¹","3.011 × 10²³ mol⁻¹"],"correct_index":0}'::jsonb,
    'a14af0bd8ce887afcc85a2505e55d01ad62ac73d8441e57b289cef369d09a384'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the value of Avogadro''s number?', ARRAY['6.022 × 10²³ mol⁻¹','6.022 × 10²⁰ mol⁻¹','6.022 × 10²⁶ mol⁻¹','3.011 × 10²³ mol⁻¹'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_static',
    'easy',
    ARRAY['molar_mass','mole_concept'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The molar mass of a substance is numerically equal to which of the following?","options":["The number of atoms in one gram of the substance","The mass in grams of one mole of that substance","The mass in kilograms of Avogadro''s number of molecules","The number of moles in one gram of the substance"],"correct_index":1}'::jsonb,
    'f830531660468aa757bd284649085854f8c5a9604dde709c662824b13495d82f'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The molar mass of a substance is numerically equal to which of the following?', ARRAY['The number of atoms in one gram of the substance','The mass in grams of one mole of that substance','The mass in kilograms of Avogadro''s number of molecules','The number of moles in one gram of the substance'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_static',
    'medium',
    ARRAY['mole_concept','particle_count','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following samples contains the greatest number of molecules? (Molar masses: CH₄ = 16.04 g/mol)","options":["1.0 mol of CH₄","3.0 × 10²³ molecules of CH₄","30.0 g of CH₄","12.04 g of CH₄"],"correct_index":2}'::jsonb,
    'f14c7a0d346e2dd98dd5aedfc9381cfa13e2c4e70a88fbeca8943d3411b1f59d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following samples contains the greatest number of molecules? (Molar masses: CH₄ = 16.04 g/mol)', ARRAY['1.0 mol of CH₄','3.0 × 10²³ molecules of CH₄','30.0 g of CH₄','12.04 g of CH₄'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_static',
    'easy',
    ARRAY['mass_spectrometry','isotopes'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What information can be directly obtained from the mass spectrum of a pure element?","options":["The number of protons in the nucleus","The total number of electrons in the atom","The chemical formula of the element''s most stable compound","The masses and relative abundances of its isotopes"],"correct_index":3}'::jsonb,
    '874e16ba9ae26128658942081a61472797515ace4ef088d29857191ae784ca08'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What information can be directly obtained from the mass spectrum of a pure element?', ARRAY['The number of protons in the nucleus','The total number of electrons in the atom','The chemical formula of the element''s most stable compound','The masses and relative abundances of its isotopes'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_static',
    'medium',
    ARRAY['average_atomic_mass','isotopes','mass_spectrometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A mass spectrum of element X shows two peaks: one at m/z = 69 with a relative intensity of 60.1% and one at m/z = 71 with a relative intensity of 39.9%. Which of the following is the best estimate of the average atomic mass of element X?","options":["69.8 amu","69.0 amu","71.0 amu","70.0 amu"],"correct_index":0}'::jsonb,
    '458ec71d47bbecfe3f1b084bcd6cfb63968a88ab849586c3ba7a50bad2c1d62d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A mass spectrum of element X shows two peaks: one at m/z = 69 with a relative intensity of 60.1% and one at m/z = 71 with a relative intensity of 39.9%. Which of the following is the best estimate of the average atomic mass of element X?', ARRAY['69.8 amu','69.0 amu','71.0 amu','70.0 amu'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_static',
    'hard',
    ARRAY['mass_spectrometry','isotopes','element_identification'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A mass spectrum of a pure element shows two peaks: m/z = 63 with a relative intensity of 69.2% and m/z = 65 with a relative intensity of 30.8%. Which element is most likely being analyzed?","options":["Zinc (Zn)","Copper (Cu)","Nickel (Ni)","Gallium (Ga)"],"correct_index":1}'::jsonb,
    '219d0aa04c4654da767e265ea26d18dc9eb672c67c7e9ed70f61d8b2f0399ee2'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A mass spectrum of a pure element shows two peaks: m/z = 63 with a relative intensity of 69.2% and m/z = 65 with a relative intensity of 30.8%. Which element is most likely being analyzed?', ARRAY['Zinc (Zn)','Copper (Cu)','Nickel (Ni)','Gallium (Ga)'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_static',
    'easy',
    ARRAY['law_of_definite_proportions','pure_substance'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The law of definite proportions states that a pure compound always contains its elements in what ratio?","options":["A fixed ratio by volume","A ratio equal to the atomic number of each element","A fixed ratio by mass","A ratio determined by the temperature of formation"],"correct_index":2}'::jsonb,
    '3a0d7ae5b92d873edbab1dbc95e2420d7aaf0245864f4b45a022b64cbbf92a55'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The law of definite proportions states that a pure compound always contains its elements in what ratio?', ARRAY['A fixed ratio by volume','A ratio equal to the atomic number of each element','A fixed ratio by mass','A ratio determined by the temperature of formation'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_static',
    'medium',
    ARRAY['empirical_formula','percent_composition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What does elemental analysis of a pure compound allow a chemist to directly determine?","options":["The molecular formula of the compound","The three-dimensional structure of the compound","The type of intramolecular bonding present","The empirical formula of the compound"],"correct_index":3}'::jsonb,
    '7fbaccec7f753e6de65e529493785ec6d4ea15d2f483ffe3c26d70de846c0de4'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What does elemental analysis of a pure compound allow a chemist to directly determine?', ARRAY['The molecular formula of the compound','The three-dimensional structure of the compound','The type of intramolecular bonding present','The empirical formula of the compound'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_static',
    'hard',
    ARRAY['empirical_formula','molecular_formula','molar_mass'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A compound has an empirical formula of CH₂O and a measured molar mass of 90.0 g/mol. What is the molecular formula of this compound?","options":["C₂H₄O₂","CH₂O","C₃H₆O₃","C₄H₈O₄"],"correct_index":2}'::jsonb,
    'ccfeca78f7514ad4fdfa591e5ff9e46c48f2b99a7b209a312c966079594ebdbc'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A compound has an empirical formula of CH₂O and a measured molar mass of 90.0 g/mol. What is the molecular formula of this compound?', ARRAY['C₂H₄O₂','CH₂O','C₃H₆O₃','C₄H₈O₄'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'mc_static',
    'easy',
    ARRAY['mixtures','pure_substance'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best distinguishes a pure substance from a mixture?","options":["A pure substance is always a solid, while a mixture can be any phase.","A pure substance contains only one type of atom, molecule, or formula unit, while a mixture contains two or more types whose proportions can vary.","A pure substance cannot be broken down by physical means, while a mixture can.","A pure substance has a definite color, while a mixture does not."],"correct_index":1}'::jsonb,
    '6a7bf39f809a519d4ef89b875889aa12891c79201b29d2803e44155e3db2c18c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best distinguishes a pure substance from a mixture?', ARRAY['A pure substance is always a solid, while a mixture can be any phase.','A pure substance contains only one type of atom, molecule, or formula unit, while a mixture contains two or more types whose proportions can vary.','A pure substance cannot be broken down by physical means, while a mixture can.','A pure substance has a definite color, while a mixture does not.'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'mc_static',
    'medium',
    ARRAY['elemental_analysis','mixtures','purity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A chemist uses elemental analysis on an unknown solid and finds it contains 75.0% C and 25.0% H by mass. Which conclusion is best supported by this data?","options":["The solid must be a pure compound with molecular formula CH₄.","The solid is definitely a mixture because it contains more than one element.","The empirical formula of the solid has a C:H mole ratio of approximately 1:4.","No conclusion can be drawn without knowing the molar mass."],"correct_index":2}'::jsonb,
    'fe621b50a4946a612d74402bca423839b2da21423fc32fb8ce4fe1a3389d6309'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A chemist uses elemental analysis on an unknown solid and finds it contains 75.0% C and 25.0% H by mass. Which conclusion is best supported by this data?', ARRAY['The solid must be a pure compound with molecular formula CH₄.','The solid is definitely a mixture because it contains more than one element.','The empirical formula of the solid has a C:H mole ratio of approximately 1:4.','No conclusion can be drawn without knowing the molar mass.'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic Structure and Electron Configuration',
    'mc_static',
    'easy',
    ARRAY['electron_configuration','core_electrons','valence_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best describes core electrons?","options":["Electrons in the highest occupied energy level of the atom","Electrons that are shared between two atoms","Electrons that have been removed from the atom to form a cation","Electrons occupying inner shells that are not in the outermost energy level of the atom"],"correct_index":3}'::jsonb,
    '07c37fcc1b14f456a2126fd8cbc3f88dc2c936b4d12d486139196a6f6a0055a2'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes core electrons?', ARRAY['Electrons in the highest occupied energy level of the atom','Electrons that are shared between two atoms','Electrons that have been removed from the atom to form a cation','Electrons occupying inner shells that are not in the outermost energy level of the atom'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic Structure and Electron Configuration',
    'mc_static',
    'easy',
    ARRAY['electron_configuration','aufbau_principle'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the ground-state electron configuration of sodium (Na, Z = 11)?","options":["1s²2s²2p⁶3s¹","1s²2s²2p⁶3s²","1s²2s²2p⁵3s²","1s²2s²2p⁶"],"correct_index":0}'::jsonb,
    '03fbaae2660440ef4472e6feff42a25ecceee3cd28a20950e0af6850b8c719aa'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the ground-state electron configuration of sodium (Na, Z = 11)?', ARRAY['1s²2s²2p⁶3s¹','1s²2s²2p⁶3s²','1s²2s²2p⁵3s²','1s²2s²2p⁶'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic Structure and Electron Configuration',
    'mc_static',
    'medium',
    ARRAY['electron_configuration','aufbau_principle','transition_metals'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the ground-state electron configuration of iron (Fe, Z = 26)?","options":["[Ar]3d⁸","[Ar]3d⁶4s²","[Ar]3d⁵4s²4p¹","[Ar]3d⁷4s¹"],"correct_index":1}'::jsonb,
    '0397cf957234136705cd6df9d70196d880293221ab6f739e1dcb8fcf312792eb'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the ground-state electron configuration of iron (Fe, Z = 26)?', ARRAY['[Ar]3d⁸','[Ar]3d⁶4s²','[Ar]3d⁵4s²4p¹','[Ar]3d⁷4s¹'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic Structure and Electron Configuration',
    'mc_static',
    'hard',
    ARRAY['electron_configuration','ions','aufbau_principle'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the ground-state electron configuration of the chloride ion (Cl⁻)?","options":["1s²2s²2p⁶3s²3p⁵","1s²2s²2p⁶3s²3p⁶3d¹","1s²2s²2p⁶3s²3p⁶","1s²2s²2p⁶3s¹3p⁶"],"correct_index":2}'::jsonb,
    '4b8a83bcd0df1befa7734a5c3db3f9a14c838e40bbbb6f83fdb59ee8a1cd4737'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the ground-state electron configuration of the chloride ion (Cl⁻)?', ARRAY['1s²2s²2p⁶3s²3p⁵','1s²2s²2p⁶3s²3p⁶3d¹','1s²2s²2p⁶3s²3p⁶','1s²2s²2p⁶3s¹3p⁶'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy',
    'mc_static',
    'easy',
    ARRAY['pes','binding_energy','electron_configuration'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a photoelectron spectrum (PES), what does the position (binding energy) of a peak represent?","options":["The number of electrons in the corresponding subshell","The distance of that subshell from the nucleus","The mass of an electron in that subshell","The energy required to remove an electron from the corresponding subshell"],"correct_index":3}'::jsonb,
    '7dedc0c500d16d39877621074e2ba43b9abe5db6f15cb9c454c84ad8d5c899b5'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In a photoelectron spectrum (PES), what does the position (binding energy) of a peak represent?', ARRAY['The number of electrons in the corresponding subshell','The distance of that subshell from the nucleus','The mass of an electron in that subshell','The energy required to remove an electron from the corresponding subshell'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy',
    'mc_static',
    'medium',
    ARRAY['pes','peak_height','electron_count'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a photoelectron spectrum, what does the relative height of a peak indicate?","options":["The relative number of electrons in that subshell","The binding energy of electrons in that subshell","The effective nuclear charge experienced by electrons in that subshell","The principal quantum number of the corresponding shell"],"correct_index":0}'::jsonb,
    'bd20da59d290bb44247977cfb56ced9b52573d770a3fbd5c73bb1e4908cbbcfa'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In a photoelectron spectrum, what does the relative height of a peak indicate?', ARRAY['The relative number of electrons in that subshell','The binding energy of electrons in that subshell','The effective nuclear charge experienced by electrons in that subshell','The principal quantum number of the corresponding shell'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy',
    'mc_static',
    'hard',
    ARRAY['pes','electron_configuration','element_identification'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A photoelectron spectrum shows exactly 4 peaks. Listed from highest to lowest binding energy, the relative heights of the peaks are in the ratio 1:1:3:1. Which element is most consistent with this spectrum?","options":["Sodium (Na)","Magnesium (Mg)","Silicon (Si)","Aluminum (Al)"],"correct_index":1}'::jsonb,
    'bac0ea073699ad01677d4176fa5a01e6ef897023ad2150a5a1b3d8320c285da2'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A photoelectron spectrum shows exactly 4 peaks. Listed from highest to lowest binding energy, the relative heights of the peaks are in the ratio 1:1:3:1. Which element is most consistent with this spectrum?', ARRAY['Sodium (Na)','Magnesium (Mg)','Silicon (Si)','Aluminum (Al)'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Periodic Trends',
    'mc_static',
    'easy',
    ARRAY['ionization_energy','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"How does the first ionization energy generally change as you move from left to right across a period on the periodic table?","options":["It generally decreases","It remains constant","It generally increases","It alternates between increasing and decreasing with no general trend"],"correct_index":2}'::jsonb,
    'afffac62ae1f52bc3dbd000ab6d3af348b00d0eb0247f25e70a4a9a95bca5826'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'How does the first ionization energy generally change as you move from left to right across a period on the periodic table?', ARRAY['It generally decreases','It remains constant','It generally increases','It alternates between increasing and decreasing with no general trend'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Periodic Trends',
    'mc_static',
    'easy',
    ARRAY['atomic_radius','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"How does atomic radius generally change as you move down a group on the periodic table?","options":["It decreases because nuclear charge increases","It remains approximately constant within a group","It increases only for metals and decreases for nonmetals","It increases because each successive element has an additional electron shell"],"correct_index":3}'::jsonb,
    'd7ff365c73f32e850062c721bb3a65a584c54b85404792fad626b0cf7282ffa2'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'How does atomic radius generally change as you move down a group on the periodic table?', ARRAY['It decreases because nuclear charge increases','It remains approximately constant within a group','It increases only for metals and decreases for nonmetals','It increases because each successive element has an additional electron shell'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Periodic Trends',
    'mc_static',
    'medium',
    ARRAY['ionization_energy','periodic_trends','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly orders Period 3 elements from lowest to highest first ionization energy?","options":["Na < Mg < Cl < Ar","Na < Cl < Mg < Ar","Ar < Cl < Mg < Na","Mg < Na < Ar < Cl"],"correct_index":0}'::jsonb,
    '5126360337883b4ae01f16282c07ca4c95e69ce87df79977198bf0ac56d0112c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly orders Period 3 elements from lowest to highest first ionization energy?', ARRAY['Na < Mg < Cl < Ar','Na < Cl < Mg < Ar','Ar < Cl < Mg < Na','Mg < Na < Ar < Cl'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Periodic Trends',
    'mc_static',
    'hard',
    ARRAY['ionization_energy','half_filled_subshell','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The first ionization energy of oxygen (O) is lower than that of nitrogen (N), despite oxygen having a higher atomic number. Which of the following best explains this observation?","options":["Oxygen has more protons, which increases electron-electron repulsion in the outer shell.","Nitrogen''s half-filled 2p subshell is especially stable, making it harder to remove an electron from nitrogen than from oxygen.","Nitrogen''s 2p electrons are held closer to the nucleus than oxygen''s 2p electrons.","Oxygen''s higher effective nuclear charge lowers the energy needed to remove a valence electron."],"correct_index":1}'::jsonb,
    '939bc0994a9cadabe12d96319863e4b78a20a2cdd8c76f4d0dbf833cc00bb120'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The first ionization energy of oxygen (O) is lower than that of nitrogen (N), despite oxygen having a higher atomic number. Which of the following best explains this observation?', ARRAY['Oxygen has more protons, which increases electron-electron repulsion in the outer shell.','Nitrogen''s half-filled 2p subshell is especially stable, making it harder to remove an electron from nitrogen than from oxygen.','Nitrogen''s 2p electrons are held closer to the nucleus than oxygen''s 2p electrons.','Oxygen''s higher effective nuclear charge lowers the energy needed to remove a valence electron.'], 1, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Valence Electrons and Ionic Compounds',
    'mc_static',
    'easy',
    ARRAY['valence_electrons','ionic_charge','periodic_table'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the typical ionic charge of an element in Group 2 of the periodic table?","options":["2−","1+","2+","1−"],"correct_index":2}'::jsonb,
    '721078fa95dda9dce32fbded38adfb72d3f829aa187be2fd3773d1c254b0e9d5'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the typical ionic charge of an element in Group 2 of the periodic table?', ARRAY['2−','1+','2+','1−'], 2, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Valence Electrons and Ionic Compounds',
    'mc_static',
    'medium',
    ARRAY['periodic_table','analogous_compounds','valence_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Sodium (Na) reacts with chlorine to form NaCl. Which element is most likely to react with chlorine to form a compound with the same 1:1 formula type?","options":["Magnesium (Mg)","Calcium (Ca)","Sulfur (S)","Potassium (K)"],"correct_index":3}'::jsonb,
    'a9e7cb97243fd7364ef05014bbe99e5530ef36678b2298e43290ef8432183447'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Sodium (Na) reacts with chlorine to form NaCl. Which element is most likely to react with chlorine to form a compound with the same 1:1 formula type?', ARRAY['Magnesium (Mg)','Calcium (Ca)','Sulfur (S)','Potassium (K)'], 3, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Valence Electrons and Ionic Compounds',
    'mc_static',
    'hard',
    ARRAY['reactivity','valence_electrons','ionization_energy','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best explains why potassium (K) is more reactive than sodium (Na) toward water?","options":["K has a lower first ionization energy than Na because K''s valence electron is in a shell farther from the nucleus, experiencing lower effective nuclear charge.","K has more valence electrons than Na, making it easier to lose electrons.","K has a higher electronegativity than Na, which increases its reactivity.","K''s valence electron is in the 3s subshell, while Na''s valence electron is in the 4s subshell."],"correct_index":0}'::jsonb,
    '4259bb2a4302376e0e5e8693a9035fa02aa0aa37313b16c184429eb1dbf617d8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best explains why potassium (K) is more reactive than sodium (Na) toward water?', ARRAY['K has a lower first ionization energy than Na because K''s valence electron is in a shell farther from the nucleus, experiencing lower effective nuclear charge.','K has more valence electrons than Na, making it easier to lose electrons.','K has a higher electronegativity than Na, which increases its reactivity.','K''s valence electron is in the 3s subshell, while Na''s valence electron is in the 4s subshell.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'easy',
    ARRAY['mole_concept','molar_mass','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"How many moles of water (H₂O) are in a {{a}}-gram sample? (Molar mass of H₂O = 18.02 g/mol)","params":{"a":{"min":36,"max":180,"step":18}},"answer_formula":"a / 18.02","precision":2,"unit":"mol","distractors":[{"formula":"a * 18.02","error_type":"multiplied_by_molar_mass_instead_of_dividing"},{"formula":"a / 2","error_type":"divided_by_number_of_hydrogen_atoms_instead_of_molar_mass"},{"formula":"18.02 / a","error_type":"inverted_ratio"}]}'::jsonb,
    '94bc253b0bdecbb0297e5a2090a621bf12770b051910b441a2a98476f0d3553c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'easy',
    ARRAY['mole_concept','molar_mass','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the mass in grams of {{a}} moles of NaCl? (Molar mass of NaCl = 58.44 g/mol)","params":{"a":{"min":2,"max":6,"step":1}},"answer_formula":"a * 58.44","precision":1,"unit":"g","distractors":[{"formula":"a / 58.44","error_type":"divided_by_molar_mass_instead_of_multiplying"},{"formula":"a + 58.44","error_type":"added_molar_mass_instead_of_multiplying"},{"formula":"58.44 * 2 * a","error_type":"doubled_molar_mass_incorrectly"}]}'::jsonb,
    '81dc6782c2b0f1018908039ede65083803c3cd33af4ec954c36f11327bb068f8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'easy',
    ARRAY['mole_concept','avogadro','particle_count'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A sample contains {{a}} moles of CO₂ molecules. How many individual CO₂ molecules are in this sample? (Avogadro''s number = 6.022 × 10²³ mol⁻¹)","params":{"a":{"min":2,"max":10,"step":2}},"answer_formula":"a * 6.022e23","precision":3,"unit":"molecules","distractors":[{"formula":"a / 6.022e23","error_type":"divided_by_avogadro_instead_of_multiplying"},{"formula":"a * 6.022e23 / 3","error_type":"divided_by_number_of_atoms_in_CO2"},{"formula":"6.022e23 / a","error_type":"inverted_ratio"}]}'::jsonb,
    '3c1b26923845e6a23f651a78155ca21236903b8192cc7a0b199cdb096bfa1be8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'medium',
    ARRAY['mole_concept','molar_mass','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A sample of carbon dioxide (CO₂) has a mass of {{a}} grams. How many moles of CO₂ are in this sample? (Molar mass of CO₂ = 44.01 g/mol)","params":{"a":{"min":88,"max":440,"step":44}},"answer_formula":"a / 44.01","precision":2,"unit":"mol","distractors":[{"formula":"a * 44.01","error_type":"multiplied_by_molar_mass_instead_of_dividing"},{"formula":"44.01 / a","error_type":"inverted_ratio"},{"formula":"a / 22.0","error_type":"used_molar_volume_at_STP_instead_of_molar_mass"}]}'::jsonb,
    '095cd07c8a7f78e61765d6fc7487c98763141f1cd89b973925b08e7e07514a05'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'medium',
    ARRAY['mole_concept','avogadro','particle_count'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A sample contains {{a}} × 10²³ atoms of carbon. How many moles of carbon atoms does this represent? (Avogadro''s number = 6.022 × 10²³ mol⁻¹)","params":{"a":{"min":1,"max":5,"step":0.5}},"answer_formula":"a / 6.022","precision":3,"unit":"mol","distractors":[{"formula":"a * 6.022","error_type":"multiplied_by_avogadro_instead_of_dividing"},{"formula":"a / 2","error_type":"divided_by_number_of_electrons_instead_of_avogadro"},{"formula":"a / 3.011","error_type":"used_half_avogadro_number"}]}'::jsonb,
    '6448352d57f37e8bf800c369b5ff3707653e768d84dbed9704e3d545f893e3a6'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'mc_numeric',
    'medium',
    ARRAY['molar_mass','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the mass in grams of {{a}} moles of iron (Fe)? (Molar mass of Fe = 55.85 g/mol)","params":{"a":{"min":2,"max":6,"step":1}},"answer_formula":"a * 55.85","precision":1,"unit":"g","distractors":[{"formula":"a / 55.85","error_type":"divided_by_molar_mass_instead_of_multiplying"},{"formula":"a + 55.85","error_type":"added_molar_mass_instead_of_multiplying"},{"formula":"55.85 / a","error_type":"inverted_ratio"}]}'::jsonb,
    '1b71b466636b6c5d2bca407c24f1b39ce39cf22a2b84b51a28b075e0c070be7e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_numeric',
    'medium',
    ARRAY['average_atomic_mass','isotopes','weighted_average'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A hypothetical element has two stable isotopes: Isotope A with mass 10.01 amu and {{a}}% natural abundance, and Isotope B with mass 11.01 amu with the remaining abundance. What is the average atomic mass of this element?","params":{"a":{"min":60,"max":90,"step":10}},"answer_formula":"10.01 * a / 100 + 11.01 * (1 - a / 100)","precision":2,"unit":"amu","distractors":[{"formula":"10.01 * (1 - a / 100) + 11.01 * a / 100","error_type":"swapped_abundances_for_the_two_isotopes"},{"formula":"10.01 * a / 100 + 11.01 * a / 100","error_type":"used_same_abundance_for_both_isotopes_instead_of_complement"},{"formula":"10.01 + 11.01 * a / 100","error_type":"omitted_abundance_factor_for_first_isotope"}]}'::jsonb,
    '0b876b8fcbfa5ef74e85cc7688b170585ca1f36ad723748865842b2ae2abbabb'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_numeric',
    'medium',
    ARRAY['average_atomic_mass','isotopes','weighted_average'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An element has two stable isotopes with masses of {{a}} amu and {{b}} amu, respectively. If the lighter isotope has 60.0% natural abundance, what is the average atomic mass of the element?","params":{"a":{"min":6,"max":8,"step":0.5},"b":{"min":9,"max":11,"step":0.5}},"answer_formula":"0.60 * a + 0.40 * b","precision":2,"unit":"amu","distractors":[{"formula":"0.40 * a + 0.60 * b","error_type":"swapped_abundances_assigning_60_percent_to_heavier_isotope"},{"formula":"(a + b) / 2","error_type":"calculated_simple_average_ignoring_natural_abundances"},{"formula":"0.24 * a * b","error_type":"multiplied_isotope_masses_and_abundances_instead_of_summing"}]}'::jsonb,
    '6be51bc5c685c6f6d28350626588b0b39d882768c3bb7c8e724577d8ff9cbe2a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'mc_numeric',
    'hard',
    ARRAY['average_atomic_mass','isotopes','relative_abundance'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Chlorine has two naturally occurring isotopes: Cl-35 (mass = 34.97 amu) and Cl-37 (mass = 36.97 amu). If the average atomic mass of chlorine is {{a}} amu, what is the fractional abundance of Cl-35?","params":{"a":{"min":35.1,"max":35.8,"step":0.1}},"answer_formula":"(36.97 - a) / 2","precision":3,"unit":"","distractors":[{"formula":"(a - 34.97) / 2","error_type":"calculated_fractional_abundance_of_Cl37_instead_of_Cl35"},{"formula":"(36.97 - a) / 36.97","error_type":"used_heavier_isotope_mass_as_denominator_instead_of_mass_difference"},{"formula":"(36.97 - a) / 71.94","error_type":"used_sum_of_isotope_masses_as_denominator_instead_of_mass_difference"}]}'::jsonb,
    '3a9cacfca21660e354408707300cf43c16ee269f2d818d3986a88389184a18f6'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_numeric',
    'medium',
    ARRAY['percent_composition','molar_mass'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A binary compound has the formula AB where A has a molar mass of {{a}} g/mol and B has a molar mass of {{b}} g/mol. What is the percent by mass of A in the compound?","params":{"a":{"min":10,"max":25,"step":5},"b":{"min":50,"max":80,"step":10}},"answer_formula":"a / (a + b) * 100","precision":1,"unit":"%","distractors":[{"formula":"b / (a + b) * 100","error_type":"calculated_percent_of_element_B_instead_of_A"},{"formula":"a / b * 100","error_type":"used_molar_mass_of_B_alone_as_denominator_instead_of_total"},{"formula":"(a + b) / a * 100","error_type":"inverted_the_ratio"}]}'::jsonb,
    '39fa3e84e73fbab42d57d3421e7a6e182632e7c2b3d338730106b1dbd0a6830b'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_numeric',
    'medium',
    ARRAY['percent_composition','molar_mass','stoichiometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A compound contains {{a}} moles of C atoms and 2 moles of O atoms per formula unit. What is the percent by mass of carbon in the compound? (Molar masses: C = 12.01 g/mol, O = 16.00 g/mol)","params":{"a":{"min":1,"max":3,"step":1}},"answer_formula":"(a * 12.01) / (a * 12.01 + 2 * 16.00) * 100","precision":1,"unit":"%","distractors":[{"formula":"(2 * 16.00) / (a * 12.01 + 2 * 16.00) * 100","error_type":"calculated_percent_of_oxygen_instead_of_carbon"},{"formula":"(a * 12.01) / (a * 12.01 + 16.00) * 100","error_type":"forgot_coefficient_of_2_for_oxygen"},{"formula":"a / (a + 2) * 100","error_type":"used_mole_ratio_instead_of_mass_ratio"}]}'::jsonb,
    'c30976469b60581f585e2d4eb789dd6c387462cbb7254cecfe491083a5e22af1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'mc_numeric',
    'hard',
    ARRAY['percent_composition','mole_ratio','empirical_formula'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A compound contains {{a}}% by mass of element X (molar mass = 14.01 g/mol) and the remainder is element Y (molar mass = 16.00 g/mol). What is the mole ratio of X to Y in this compound?","params":{"a":{"min":25,"max":45,"step":5}},"answer_formula":"(a / 14.01) / ((100 - a) / 16.00)","precision":2,"unit":"mol X per mol Y","distractors":[{"formula":"(a / 16.00) / ((100 - a) / 14.01)","error_type":"swapped_molar_masses_of_the_two_elements"},{"formula":"a / (100 - a)","error_type":"used_mass_percent_ratio_instead_of_mole_ratio"},{"formula":"(100 - a) / a","error_type":"calculated_inverted_ratio_of_Y_to_X_instead_of_X_to_Y"}]}'::jsonb,
    'a852328b57f54b019828e01a336468f18fe6e6250016a28141fba8400a13587e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'mc_numeric',
    'medium',
    ARRAY['mass_percent','mixtures'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A mixture contains {{a}} grams of NaCl and {{b}} grams of KCl. What is the mass percent of NaCl in the mixture?","params":{"a":{"min":10,"max":30,"step":5},"b":{"min":35,"max":65,"step":5}},"answer_formula":"a / (a + b) * 100","precision":1,"unit":"%","distractors":[{"formula":"b / (a + b) * 100","error_type":"calculated_mass_percent_of_KCl_instead_of_NaCl"},{"formula":"a / b * 100","error_type":"used_mass_of_KCl_alone_as_denominator"},{"formula":"(a + b) / a * 100","error_type":"inverted_the_ratio"}]}'::jsonb,
    '2b535ea6ffd4c25924ec3f108896702b249d045d161559ba6cc53ce522db27b3'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'mc_numeric',
    'medium',
    ARRAY['mass_percent','mixtures','dimensional_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A mixture has a total mass of {{b}} grams. If the mixture is {{a}}% by mass NaCl, how many grams of NaCl are present?","params":{"a":{"min":20,"max":60,"step":10},"b":{"min":50,"max":90,"step":20}},"answer_formula":"a * b / 100","precision":1,"unit":"g","distractors":[{"formula":"b / a * 100","error_type":"inverted_and_incorrectly_multiplied_by_100"},{"formula":"(a + b) / 100","error_type":"added_percent_and_total_mass_then_divided_by_100"},{"formula":"a * b","error_type":"forgot_to_divide_by_100"}]}'::jsonb,
    'a76d094691be20e26375cec70c67c55772b8c93cf4ae48b0826c284f44c05f8a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'mc_numeric',
    'easy',
    ARRAY['percent_purity','elemental_analysis','mixtures'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An impure sample of magnesium (Mg) with total mass {{b}} grams contains {{a}} grams of pure Mg. What is the percent purity of Mg in the sample?","params":{"a":{"min":5,"max":20,"step":5},"b":{"min":50,"max":90,"step":10}},"answer_formula":"a / b * 100","precision":1,"unit":"%","distractors":[{"formula":"(b - a) / b * 100","error_type":"calculated_percent_impurity_instead_of_percent_purity"},{"formula":"b / a * 100","error_type":"inverted_the_ratio"},{"formula":"a / (b - a) * 100","error_type":"used_mass_of_impurities_as_denominator_instead_of_total_mass"}]}'::jsonb,
    'cb01588381d136f07728f9d8b87f22b5fd38be0c81fcb9eb4816f40b1dc1fa28'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Moles and Molar Mass',
    'fr_static',
    'easy',
    ARRAY['avogadro','mole_concept'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What name is given to the constant 6.022 × 10²³ mol⁻¹, which represents the number of constituent particles in exactly one mole of a substance?","accepted_answers":["avogadro''s number","avogadro number","avogadro''s constant","the avogadro constant"],"semantic_fallback":true}'::jsonb,
    '3981eb86a704a7958242bbe853f03cb5f6e0ec8344925006158bf0241bae2547'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'fr_static',
    'easy',
    ARRAY['isotopes','mass_spectrometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What term describes atoms of the same element that have the same number of protons but different numbers of neutrons, and therefore different masses?","accepted_answers":["isotopes","isotope"],"semantic_fallback":true}'::jsonb,
    '80801bc28cd477a2090c35ab0d79055fd6da52223f1cc99464d6d2ec4880db8e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'fr_static',
    'medium',
    ARRAY['empirical_formula','percent_composition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the name for the chemical formula that expresses the simplest whole-number ratio of atoms of each element in a compound?","accepted_answers":["empirical formula","simplest formula","simplest whole-number ratio formula"],"semantic_fallback":true}'::jsonb,
    '4ac57b1966520a4eb9a5c1c017a3ac614473c9259063bc658e578035d4f5494c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Composition of Mixtures',
    'fr_static',
    'medium',
    ARRAY['elemental_analysis','mixtures'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What type of analytical technique is used to determine the relative amounts of each element by mass in an unknown substance, and can be used to assess its purity?","accepted_answers":["elemental analysis","combustion analysis"],"semantic_fallback":true}'::jsonb,
    '9a9816aaf8e4edeb23624704c667ee7fcf4aceec9ff7684472b97ae979598aa5'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic Structure and Electron Configuration',
    'fr_static',
    'medium',
    ARRAY['valence_electrons','electron_configuration'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What term describes the electrons in an atom''s outermost energy level that are primarily responsible for the atom''s chemical bonding behavior?","accepted_answers":["valence electrons","outer electrons","outer shell electrons","outermost electrons"],"semantic_fallback":true}'::jsonb,
    '8177e31489d25767253d4379e2d8d50cdccd6e4b47af2bb8be1844b32fc512e8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy',
    'fr_static',
    'medium',
    ARRAY['pes','electron_configuration','binding_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What spectroscopic technique measures the binding energies of electrons in each subshell of an atom, producing a spectrum that can be used to verify or determine an atom''s electron configuration?","accepted_answers":["photoelectron spectroscopy","pes","x-ray photoelectron spectroscopy","xps"],"semantic_fallback":true}'::jsonb,
    '569768f4c981b9c44f4e9ec5fed0c308b0492493c0e66042b00bedfb8d152bf6'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Periodic Trends',
    'fr_static',
    'hard',
    ARRAY['effective_nuclear_charge','shielding','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What concept, often abbreviated Z_eff, describes the net positive charge experienced by a valence electron after accounting for the shielding effects of core electrons?","accepted_answers":["effective nuclear charge","zeff","z effective","z_eff"],"semantic_fallback":true}'::jsonb,
    '4753a967c3675ce6d5c149c0447b802d1560908a11a9808cf318331359867f9f'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Valence Electrons and Ionic Compounds',
    'fr_static',
    'hard',
    ARRAY['valence_electrons','ionic_charge','periodic_table'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"According to the AP Chemistry curriculum, what property of an atom most directly determines its typical ionic charge when forming an ionic compound?","accepted_answers":["number of valence electrons","valence electrons","the number of valence electrons"],"semantic_fallback":true}'::jsonb,
    '2d21ae5fdd87ec6b55ff4c7d61cb62526c84ba5b82ab8098ec994729f559d2fb'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Mass Spectra of Elements',
    'fr_numeric',
    'easy',
    ARRAY['average_atomic_mass','isotopes','weighted_average'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Element X has two naturally occurring isotopes: Isotope A with a mass of 63.00 amu and {{a}}% natural abundance, and Isotope B with a mass of 65.00 amu with the remaining natural abundance. Calculate the average atomic mass of element X in amu.","params":{"a":{"min":55,"max":75,"step":5}},"answer_formula":"63.00 * a / 100 + 65.00 * (1 - a / 100)","precision":2,"unit":"amu","tolerance":0.02,"semantic_fallback":false}'::jsonb,
    '30a9b57423306be89edb7e1b07ff2a417a92afa93d93931caf8f3fae19bbafa7'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Elemental Composition of Pure Substances',
    'fr_numeric',
    'easy',
    ARRAY['percent_composition','molar_mass'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A compound contains {{a}} grams of carbon (C) and {{b}} grams of hydrogen (H) and no other elements. Calculate the percent by mass of carbon in this compound.","params":{"a":{"min":12,"max":60,"step":12},"b":{"min":1,"max":5,"step":1}},"answer_formula":"a / (a + b) * 100","precision":1,"unit":"%","tolerance":0.05,"semantic_fallback":false}'::jsonb,
    '98c28fcbcb60130d6b094e5359c3368f07af7318e3608bd7c67e8f0bb0c71ff1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'mc_static',
    'easy',
    ARRAY['coulombs_law','electrostatic_force','atomic_structure'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"According to Coulomb''s law as applied to atomic structure, how does the attractive force between the nucleus and an electron change as the distance between them increases?","options":["The attractive force decreases because force is inversely proportional to the square of the distance.","The attractive force increases because the electron gains potential energy at larger distances.","The attractive force remains constant regardless of distance.","The attractive force decreases linearly with distance."],"correct_index":0}'::jsonb,
    '4ed8351fb5c2ae0ed9b208ecaad7c03f0b821514bc2ba706a23826c3643c9f5f'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'According to Coulomb''s law as applied to atomic structure, how does the attractive force between the nucleus and an electron change as the distance between them increases?', ARRAY['The attractive force decreases because force is inversely proportional to the square of the distance.','The attractive force increases because the electron gains potential energy at larger distances.','The attractive force remains constant regardless of distance.','The attractive force decreases linearly with distance.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'mc_static',
    'medium',
    ARRAY['coulombs_law','ionization_energy','nuclear_charge'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly uses Coulomb''s law to explain why the first ionization energy of Mg²⁺ is much larger than the first ionization energy of neutral Mg?","options":["Mg²⁺ has the same number of protons as Mg but fewer electrons, so each remaining electron is held more tightly by a greater net positive charge.","Mg²⁺ has more protons than Mg, which increases the force on the outer electrons.","Mg²⁺ has more electron–electron repulsions than Mg, which raises the ionization energy.","Mg²⁺ has a larger atomic radius than Mg, placing the outer electron farther from the nucleus."],"correct_index":0}'::jsonb,
    'd3d2d7cc85be3332b01f4e50bf6bf55de33ba8845d23e6d280bba4d41b422dcf'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly uses Coulomb''s law to explain why the first ionization energy of Mg²⁺ is much larger than the first ionization energy of neutral Mg?', ARRAY['Mg²⁺ has the same number of protons as Mg but fewer electrons, so each remaining electron is held more tightly by a greater net positive charge.','Mg²⁺ has more protons than Mg, which increases the force on the outer electrons.','Mg²⁺ has more electron–electron repulsions than Mg, which raises the ionization energy.','Mg²⁺ has a larger atomic radius than Mg, placing the outer electron farther from the nucleus.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'mc_static',
    'medium',
    ARRAY['coulombs_law','ionic_bonding','lattice_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Two ionic compounds, MgO and NaF, have the same crystal structure. Using Coulomb''s law, which compound is predicted to have the stronger interionic attractions, and why?","options":["MgO, because Mg²⁺ and O²⁻ have charges of ±2, producing a larger product of charges than Na⁺ and F⁻ with charges of ±1.","NaF, because Na⁺ and F⁻ are smaller ions that pack more closely together.","MgO, because magnesium has a higher atomic mass than sodium.","NaF, because fluorine is the most electronegative element."],"correct_index":0}'::jsonb,
    'dc8943e053ac47088deefd7cd90df606980f9030ac8170e3b3d11f483af21d32'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Two ionic compounds, MgO and NaF, have the same crystal structure. Using Coulomb''s law, which compound is predicted to have the stronger interionic attractions, and why?', ARRAY['MgO, because Mg²⁺ and O²⁻ have charges of ±2, producing a larger product of charges than Na⁺ and F⁻ with charges of ±1.','NaF, because Na⁺ and F⁻ are smaller ions that pack more closely together.','MgO, because magnesium has a higher atomic mass than sodium.','NaF, because fluorine is the most electronegative element.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'mc_static',
    'easy',
    ARRAY['shielding','effective_nuclear_charge','core_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the primary role of core electrons in determining the effective nuclear charge (Z_eff) experienced by valence electrons?","options":["Core electrons shield valence electrons from the full nuclear charge, reducing the net attraction the valence electrons experience.","Core electrons increase the nuclear charge, making valence electrons harder to remove.","Core electrons are repelled by the nucleus and push valence electrons further from the atom.","Core electrons have no effect on valence electrons because they occupy different subshells."],"correct_index":0}'::jsonb,
    '7aa0338e2d83a626a2c917b029469826136c94a1d5d7d9eee20d05d5d19b19ba'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the primary role of core electrons in determining the effective nuclear charge (Z_eff) experienced by valence electrons?', ARRAY['Core electrons shield valence electrons from the full nuclear charge, reducing the net attraction the valence electrons experience.','Core electrons increase the nuclear charge, making valence electrons harder to remove.','Core electrons are repelled by the nucleus and push valence electrons further from the atom.','Core electrons have no effect on valence electrons because they occupy different subshells.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'mc_static',
    'medium',
    ARRAY['effective_nuclear_charge','periodic_trends','shielding'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Moving across Period 3 from sodium (Na) to chlorine (Cl), which of the following best explains why atomic radius decreases?","options":["The number of protons increases while the number of electron shells stays the same, so valence electrons experience a greater effective nuclear charge and are pulled closer to the nucleus.","The number of electron shells increases, pulling valence electrons closer to the nucleus.","The atomic mass increases across the period, compressing the electron cloud.","Shielding increases across Period 3, reducing the pull on valence electrons and contracting the atom."],"correct_index":0}'::jsonb,
    '3d72fea0da70e1f82ac4d31b04ede05d8da8bfefa18a8dff268d2d3165ed7dfe'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Moving across Period 3 from sodium (Na) to chlorine (Cl), which of the following best explains why atomic radius decreases?', ARRAY['The number of protons increases while the number of electron shells stays the same, so valence electrons experience a greater effective nuclear charge and are pulled closer to the nucleus.','The number of electron shells increases, pulling valence electrons closer to the nucleus.','The atomic mass increases across the period, compressing the electron cloud.','Shielding increases across Period 3, reducing the pull on valence electrons and contracting the atom.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'mc_static',
    'hard',
    ARRAY['effective_nuclear_charge','ionization_energy','shielding','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Sodium (Na, Z = 11) and magnesium (Mg, Z = 12) both have valence electrons in the 3s subshell. Which of the following best explains why Mg has a significantly higher first ionization energy than Na?","options":["Mg has one more proton than Na, increasing Z_eff experienced by the 3s electrons because the added electron provides minimal additional shielding from within the same subshell.","Mg has two valence electrons, which repel each other and make both harder to remove.","Mg''s 3s electrons are shielded by the 2p electrons more effectively than Na''s 3s electron.","Mg has a smaller nuclear radius than Na, which concentrates the nuclear charge and raises ionization energy."],"correct_index":0}'::jsonb,
    'f7708ca467f9d44472c57798d7548a795e51894333d6a05bc086a7d07489fbdd'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Sodium (Na, Z = 11) and magnesium (Mg, Z = 12) both have valence electrons in the 3s subshell. Which of the following best explains why Mg has a significantly higher first ionization energy than Na?', ARRAY['Mg has one more proton than Na, increasing Z_eff experienced by the 3s electrons because the added electron provides minimal additional shielding from within the same subshell.','Mg has two valence electrons, which repel each other and make both harder to remove.','Mg''s 3s electrons are shielded by the 2p electrons more effectively than Na''s 3s electron.','Mg has a smaller nuclear radius than Na, which concentrates the nuclear charge and raises ionization energy.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'mc_static',
    'easy',
    ARRAY['electron_configuration','ions','aufbau_principle'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the ground-state electron configuration of the Fe²⁺ ion? (Fe, Z = 26)","options":["[Ar]3d⁶","[Ar]3d⁴4s²","[Ar]3d⁵4s¹","[Ar]3d⁶4s²"],"correct_index":0}'::jsonb,
    'd23c036a84dd266dc969371cd0ef394140eda6e5e2beae2f54e5367aa19da49a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the ground-state electron configuration of the Fe²⁺ ion? (Fe, Z = 26)', ARRAY['[Ar]3d⁶','[Ar]3d⁴4s²','[Ar]3d⁵4s¹','[Ar]3d⁶4s²'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'mc_static',
    'medium',
    ARRAY['electron_configuration','subshell_order','periodic_table'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"How many total electrons are in the d subshells of a neutral nickel (Ni, Z = 28) atom in its ground state?","options":["8","10","6","2"],"correct_index":0}'::jsonb,
    '83068e78475c3f43e636a6d2500710ce4ceac3dcca597e7f3c1ec12feb749a11'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'How many total electrons are in the d subshells of a neutral nickel (Ni, Z = 28) atom in its ground state?', ARRAY['8','10','6','2'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'mc_static',
    'hard',
    ARRAY['electron_configuration','ions','transition_metals'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"When transition metal atoms form cations, electrons are lost from the 4s subshell before the 3d subshell. What ground-state electron configuration is expected for Cr³⁺? (Cr, Z = 24)","options":["[Ar]3d³","[Ar]3d²4s¹","[Ar]3d¹4s²","[Ar]3d³4s²"],"correct_index":0}'::jsonb,
    '49da0b308aaac78ef47ea2bc465f16056a5d1ef48d0694f63c7c1479f169e823'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'When transition metal atoms form cations, electrons are lost from the 4s subshell before the 3d subshell. What ground-state electron configuration is expected for Cr³⁺? (Cr, Z = 24)', ARRAY['[Ar]3d³','[Ar]3d²4s¹','[Ar]3d¹4s²','[Ar]3d³4s²'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy (Advanced)',
    'mc_static',
    'easy',
    ARRAY['pes','binding_energy','subshell','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a photoelectron spectrum, electrons in the 1s subshell appear at much higher binding energy than electrons in the 2s subshell of the same atom. Which of the following best explains this observation?","options":["1s electrons are much closer to the nucleus and experience a much stronger attractive force per Coulomb''s law.","1s electrons have higher kinetic energy than 2s electrons after being ejected.","The 1s subshell holds more electrons than the 2s subshell.","1s electrons are more effectively shielded from the nucleus than 2s electrons."],"correct_index":0}'::jsonb,
    'c2030332c3a65cd2e32ecc1fa102835cbf082c7cd61e96aee9250f1e6d65f7b3'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In a photoelectron spectrum, electrons in the 1s subshell appear at much higher binding energy than electrons in the 2s subshell of the same atom. Which of the following best explains this observation?', ARRAY['1s electrons are much closer to the nucleus and experience a much stronger attractive force per Coulomb''s law.','1s electrons have higher kinetic energy than 2s electrons after being ejected.','The 1s subshell holds more electrons than the 2s subshell.','1s electrons are more effectively shielded from the nucleus than 2s electrons.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy (Advanced)',
    'mc_static',
    'medium',
    ARRAY['pes','electron_configuration','peak_analysis'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A PES spectrum of an unknown second-period element shows three peaks. The peak at highest binding energy has a relative height of 2, the middle peak has a relative height of 2, and the peak at lowest binding energy has a relative height of 3. Which element is most consistent with this spectrum?","options":["Nitrogen (N)","Carbon (C)","Oxygen (O)","Beryllium (Be)"],"correct_index":0}'::jsonb,
    'd1e35880a81ff271a878de2d8cba7983dd641e42b66ff0d6dd3297b6e63778f4'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A PES spectrum of an unknown second-period element shows three peaks. The peak at highest binding energy has a relative height of 2, the middle peak has a relative height of 2, and the peak at lowest binding energy has a relative height of 3. Which element is most consistent with this spectrum?', ARRAY['Nitrogen (N)','Carbon (C)','Oxygen (O)','Beryllium (Be)'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy (Advanced)',
    'mc_static',
    'hard',
    ARRAY['pes','element_identification','electron_configuration','binding_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Moving from carbon (C) to silicon (Si) in the same group, the 1s peak in the PES spectrum shifts to higher binding energy. Which of the following best explains this observation?","options":["Silicon has more protons (Z = 14) than carbon (Z = 6), so the 1s electrons of silicon experience a greater nuclear charge and are held more tightly.","Silicon''s 1s electrons are farther from the nucleus because of additional electron shells, increasing their binding energy.","Silicon has more core electrons than carbon, which increases shielding and raises the binding energy of the 1s electrons.","The mass of silicon''s nucleus is greater, which slows the ejected 1s electron and produces a higher apparent binding energy."],"correct_index":0}'::jsonb,
    '427477ef0682ae670afeeb18060b7cd2fe064be2148aefc18d3a1b141fdf5697'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Moving from carbon (C) to silicon (Si) in the same group, the 1s peak in the PES spectrum shifts to higher binding energy. Which of the following best explains this observation?', ARRAY['Silicon has more protons (Z = 14) than carbon (Z = 6), so the 1s electrons of silicon experience a greater nuclear charge and are held more tightly.','Silicon''s 1s electrons are farther from the nucleus because of additional electron shells, increasing their binding energy.','Silicon has more core electrons than carbon, which increases shielding and raises the binding energy of the 1s electrons.','The mass of silicon''s nucleus is greater, which slows the ejected 1s electron and produces a higher apparent binding energy.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'mc_static',
    'easy',
    ARRAY['atomic_radius','periodic_trends','isoelectronic'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly ranks the species Na, Na⁺, and Mg²⁺ in order of increasing radius (smallest to largest)?","options":["Mg²⁺ < Na⁺ < Na","Na < Na⁺ < Mg²⁺","Na⁺ < Mg²⁺ < Na","Na < Mg²⁺ < Na⁺"],"correct_index":0}'::jsonb,
    '06618176ed74a650610f44e4b9ba33723239bb029c150212c051cd3215240435'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly ranks the species Na, Na⁺, and Mg²⁺ in order of increasing radius (smallest to largest)?', ARRAY['Mg²⁺ < Na⁺ < Na','Na < Na⁺ < Mg²⁺','Na⁺ < Mg²⁺ < Na','Na < Mg²⁺ < Na⁺'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'mc_static',
    'medium',
    ARRAY['ionic_radius','isoelectronic','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The ions O²⁻, F⁻, Na⁺, and Mg²⁺ are isoelectronic (all have 10 electrons). Which ion has the smallest radius?","options":["Mg²⁺","O²⁻","Na⁺","F⁻"],"correct_index":0}'::jsonb,
    '6c8c91296adfa5893a3f3282c3ee03bd0e22adb4b420fd3ba4421c0b1292f2a4'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The ions O²⁻, F⁻, Na⁺, and Mg²⁺ are isoelectronic (all have 10 electrons). Which ion has the smallest radius?', ARRAY['Mg²⁺','O²⁻','Na⁺','F⁻'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'mc_static',
    'medium',
    ARRAY['atomic_radius','cation_vs_atom','ionic_radius'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly explains why a cation is smaller than its parent neutral atom?","options":["Removing electrons reduces electron–electron repulsion and the remaining electrons are pulled more strongly toward the nucleus, decreasing the ionic radius.","Removing electrons adds protons to the nucleus, increasing the nuclear charge and shrinking the ion.","Cations form when the atom gains electrons, which are added to inner shells and compress the atom.","The nuclear charge decreases when a cation forms, allowing the remaining electrons to collapse inward."],"correct_index":0}'::jsonb,
    '103ad66f6a224efcccce3ea31a8a05e994e4f3c2c23410fdba46d60b916c856a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly explains why a cation is smaller than its parent neutral atom?', ARRAY['Removing electrons reduces electron–electron repulsion and the remaining electrons are pulled more strongly toward the nucleus, decreasing the ionic radius.','Removing electrons adds protons to the nucleus, increasing the nuclear charge and shrinking the ion.','Cations form when the atom gains electrons, which are added to inner shells and compress the atom.','The nuclear charge decreases when a cation forms, allowing the remaining electrons to collapse inward.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'mc_static',
    'medium',
    ARRAY['successive_ionization_energy','electron_configuration','shell_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The successive ionization energies (IE₁ through IE₅) of an unknown element are: 738, 1451, 7733, 10,540, and 13,630 kJ/mol. After which ionization does a dramatic increase in ionization energy first occur, and what does this indicate about the element?","options":["After IE₂; the element has 2 valence electrons, indicating it is in Group 2 (e.g., magnesium).","After IE₁; the element has 1 valence electron, indicating it is in Group 1.","After IE₃; the element has 3 valence electrons, indicating it is in Group 13.","After IE₄; the element has 4 valence electrons, indicating it is in Group 14."],"correct_index":0}'::jsonb,
    '047f9804c6126109ef9bb07f82e1d252951a42018ba0b117a2e3bb7a71ff6693'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The successive ionization energies (IE₁ through IE₅) of an unknown element are: 738, 1451, 7733, 10,540, and 13,630 kJ/mol. After which ionization does a dramatic increase in ionization energy first occur, and what does this indicate about the element?', ARRAY['After IE₂; the element has 2 valence electrons, indicating it is in Group 2 (e.g., magnesium).','After IE₁; the element has 1 valence electron, indicating it is in Group 1.','After IE₃; the element has 3 valence electrons, indicating it is in Group 13.','After IE₄; the element has 4 valence electrons, indicating it is in Group 14.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'mc_static',
    'hard',
    ARRAY['successive_ionization_energy','core_electrons','shell_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Why does the ionization energy always increase for each successive electron removed from the same atom?","options":["Each successive removal leaves fewer electrons to shield the remaining ones from the nuclear charge, so each subsequent electron experiences a higher effective nuclear charge and requires more energy to remove.","Each successive removal adds a proton to the nucleus, increasing the nuclear charge.","Electrons removed later are in higher-energy subshells that are farther from the nucleus.","Removing electrons increases the size of the ion, but more energy is required to work against the larger volume."],"correct_index":0}'::jsonb,
    '9379658f6e7efd4439e622128bed9846ff53c1476d7c12625c2a93ea48ffed12'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Why does the ionization energy always increase for each successive electron removed from the same atom?', ARRAY['Each successive removal leaves fewer electrons to shield the remaining ones from the nuclear charge, so each subsequent electron experiences a higher effective nuclear charge and requires more energy to remove.','Each successive removal adds a proton to the nucleus, increasing the nuclear charge.','Electrons removed later are in higher-energy subshells that are farther from the nucleus.','Removing electrons increases the size of the ion, but more energy is required to work against the larger volume.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'mc_static',
    'easy',
    ARRAY['electron_affinity','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best describes the general trend in electron affinity across a period from left to right?","options":["Electron affinity generally becomes more negative (more energy released) because increasing nuclear charge pulls added electrons more strongly.","Electron affinity generally becomes more positive (less energy released) because repulsion from existing electrons increases.","Electron affinity remains essentially constant across a period.","Electron affinity first increases then decreases symmetrically across each period."],"correct_index":0}'::jsonb,
    '5a3c9c79b3648bf94057932600c22490e23359529fcb765a3d0f0bf544395819'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes the general trend in electron affinity across a period from left to right?', ARRAY['Electron affinity generally becomes more negative (more energy released) because increasing nuclear charge pulls added electrons more strongly.','Electron affinity generally becomes more positive (less energy released) because repulsion from existing electrons increases.','Electron affinity remains essentially constant across a period.','Electron affinity first increases then decreases symmetrically across each period.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'mc_static',
    'medium',
    ARRAY['electronegativity','periodic_trends','coulombs_law','shell_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following pairs correctly lists the more electronegative element first and gives the best explanation for this ordering?","options":["F > Cs; fluorine is in Period 2 with a very high Z_eff and small atomic radius, so it attracts bonding electrons far more strongly than cesium, which has a low Z_eff and a large atomic radius.","Cs > F; cesium has more protons than fluorine, so it exerts a stronger pull on bonding electrons.","F > Cs; fluorine has fewer protons than cesium, so its nucleus does not repel electrons as strongly.","Cs > F; cesium''s valence electrons are farther from the nucleus and are therefore more easily attracted to bonding partners."],"correct_index":0}'::jsonb,
    '76d28bc36b0a73b94bc16552aa7a6cbc98a88827a5623f392b71f5e9ae186e0a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following pairs correctly lists the more electronegative element first and gives the best explanation for this ordering?', ARRAY['F > Cs; fluorine is in Period 2 with a very high Z_eff and small atomic radius, so it attracts bonding electrons far more strongly than cesium, which has a low Z_eff and a large atomic radius.','Cs > F; cesium has more protons than fluorine, so it exerts a stronger pull on bonding electrons.','F > Cs; fluorine has fewer protons than cesium, so its nucleus does not repel electrons as strongly.','Cs > F; cesium''s valence electrons are farther from the nucleus and are therefore more easily attracted to bonding partners.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'mc_static',
    'hard',
    ARRAY['electron_affinity','electronegativity','periodic_trends','exceptions'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The electron affinity of fluorine (−328 kJ/mol) is less negative than that of chlorine (−349 kJ/mol), even though fluorine is more electronegative. Which explanation is most consistent with the shell model and Coulomb''s law?","options":["Fluorine''s 2p subshell is very compact, so adding a second electron causes significant electron–electron repulsion in a small volume, partially offsetting the strong nuclear attraction.","Chlorine has more core electrons, which shield the nuclear charge and allow the added electron to enter more easily.","Fluorine''s high electronegativity means it already holds its electrons very tightly, leaving no room for an additional electron.","Chlorine has a lower nuclear charge than fluorine, so there is less repulsion when an electron is added."],"correct_index":0}'::jsonb,
    'ff98f8cf740dec78483a6c7a5d8a4fc6c6fd879f06a6d06ff110b41d2cc93da6'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The electron affinity of fluorine (−328 kJ/mol) is less negative than that of chlorine (−349 kJ/mol), even though fluorine is more electronegative. Which explanation is most consistent with the shell model and Coulomb''s law?', ARRAY['Fluorine''s 2p subshell is very compact, so adding a second electron causes significant electron–electron repulsion in a small volume, partially offsetting the strong nuclear attraction.','Chlorine has more core electrons, which shield the nuclear charge and allow the added electron to enter more easily.','Fluorine''s high electronegativity means it already holds its electrons very tightly, leaving no room for an additional electron.','Chlorine has a lower nuclear charge than fluorine, so there is less repulsion when an electron is added.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'mc_numeric',
    'easy',
    ARRAY['coulombs_law','electrostatic_force','charge'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"According to Coulomb''s law, the force between two charged particles is proportional to q₁ × q₂ / r². If the charge on one particle is doubled (multiplied by {{a}}) while the distance between them is held constant, by what factor does the force change?","params":{"a":{"min":2,"max":5,"step":1}},"answer_formula":"a","precision":1,"unit":"× original force","distractors":[{"formula":"a * a","error_type":"squared_the_charge_factor_instead_of_using_it_linearly"},{"formula":"a / 2","error_type":"halved_the_factor_incorrectly"},{"formula":"1 / a","error_type":"inverted_the_relationship"}]}'::jsonb,
    '8e4ff49cc5b970f2434f565687d094482a6265f1c861c29269e5714c239d3fff'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'mc_numeric',
    'medium',
    ARRAY['coulombs_law','force_distance_relationship'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The electrostatic force between two charged particles is F at distance r. If the distance is increased by a factor of {{a}} (i.e., new distance = {{a}} × r), by what factor does the force change? Express your answer as a fraction (new force / original force).","params":{"a":{"min":2,"max":5,"step":1}},"answer_formula":"1 / (a * a)","precision":3,"unit":"× original force","distractors":[{"formula":"1 / a","error_type":"used_linear_inverse_instead_of_inverse_square"},{"formula":"a * a","error_type":"multiplied_instead_of_divided_by_squared_factor"},{"formula":"1 / (a * a * a)","error_type":"used_inverse_cube_instead_of_inverse_square"}]}'::jsonb,
    'd051d61c42b148d1757dd97ab8a61122d08bda4fb173e8c86f3802cdbba29efd'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'mc_numeric',
    'easy',
    ARRAY['effective_nuclear_charge','shielding','electron_configuration'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A simplified model estimates Z_eff ≈ Z − S, where Z is the atomic number and S is the number of core (inner-shell) electrons acting as shields. For an element with atomic number {{a}} and {{b}} core electrons, what is the estimated Z_eff experienced by the valence electrons?","params":{"a":{"min":11,"max":18,"step":1},"b":{"min":2,"max":10,"step":2}},"answer_formula":"a - b","precision":0,"unit":"","distractors":[{"formula":"a + b","error_type":"added_core_electrons_instead_of_subtracting"},{"formula":"b - a","error_type":"subtracted_atomic_number_from_core_electrons"},{"formula":"a * b","error_type":"multiplied_atomic_number_by_core_electrons_instead_of_subtracting"}]}'::jsonb,
    'cfbf1bc1eef79ed4ff5485e751051261c0d5bdac52d0c3a216323d2d5be98d58'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Photoelectron Spectroscopy (Advanced)',
    'mc_numeric',
    'medium',
    ARRAY['pes','electron_count','peak_height_ratio'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a PES spectrum, the 2s peak and 2p peak heights are in the ratio 1 : {{a}} (2s : 2p). Given that the 2s subshell always holds 2 electrons, how many electrons does the 2p subshell contain for this atom?","params":{"a":{"min":1,"max":3,"step":1}},"answer_formula":"2 * a","precision":0,"unit":"electrons","distractors":[{"formula":"3 * a","error_type":"tripled_ratio_instead_of_doubling_relative_to_2s_count"},{"formula":"6 / a","error_type":"divided_max_2p_capacity_by_ratio_giving_wrong_electron_count"},{"formula":"a * 4","error_type":"multiplied_ratio_by_4_confusing_orbital_count_with_reference_subshell_electron_count"}]}'::jsonb,
    '9c1087e7a1ab4f42642d2e634ae5f4a5da9ab383534b40c54e04240485b87d90'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'mc_numeric',
    'medium',
    ARRAY['ionization_energy','electron_configuration','group_identification'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An element has {{a}} valence electrons, and the ratio of its (n+1)th to nth successive ionization energy shows a dramatic jump after removing all valence electrons. If the first ionization energy is X, a student expects the next large jump at ionization number {{a}} + 1. How many valence electrons does this element have according to this data?","params":{"a":{"min":1,"max":4,"step":1}},"answer_formula":"a","precision":0,"unit":"valence electrons","distractors":[{"formula":"a + 1","error_type":"counted_one_extra_valence_electron_misreading_the_jump_position"},{"formula":"a - 1","error_type":"undercounted_by_one_valence_electron"},{"formula":"a + 2","error_type":"misread_the_jump_as_occurring_two_steps_beyond_the_last_valence_electron"}]}'::jsonb,
    '808c8c998f0ea9001c4a403cfe7e93dc6c8741f1876272030fdc6b3a3c4c2c54'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'mc_numeric',
    'medium',
    ARRAY['atomic_radius','group_trend','shell_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The atomic radii of the alkali metals increase going down Group 1. If Li has radius r₀ and each successive element adds approximately {{a}} pm to the radius, what would be the expected radius of the 4th alkali metal (K) relative to Li? Express as r₀ + Δ, where Δ = the total increase.","params":{"a":{"min":60,"max":100,"step":10}},"answer_formula":"3 * a","precision":0,"unit":"pm (added to r₀)","distractors":[{"formula":"4 * a","error_type":"used_4_steps_instead_of_3_steps_below_Li"},{"formula":"2 * a","error_type":"used_2_steps_instead_of_3_steps_below_Li"},{"formula":"a","error_type":"used_only_one_step_of_increase"}]}'::jsonb,
    '3c2743a5f4c373e4c6b9a2a7bfd077a6e763b1a351706c3297ba55ace84f9203'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'mc_numeric',
    'easy',
    ARRAY['electron_configuration','valence_electrons','periodic_table'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An element is in Period 3 and Group {{a}} of the periodic table (where Group numbers 1–18 apply; consider only main-group elements 1–2 and 13–18). How many valence electrons does a neutral atom of this element have?","params":{"a":{"min":1,"max":2,"step":1}},"answer_formula":"a","precision":0,"unit":"valence electrons","distractors":[{"formula":"a + 8","error_type":"added_8_to_group_number_for_main_group_elements_incorrectly"},{"formula":"8 - a","error_type":"subtracted_group_from_8_giving_wrong_valence_count"},{"formula":"a * 2","error_type":"doubled_group_number_instead_of_using_it_directly"}]}'::jsonb,
    'a78e0e1d04a74f86d701b268bfdcddf99f5e4bab099973730a047b1a2d2e600d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'mc_numeric',
    'medium',
    ARRAY['electron_configuration','subshell_capacity','orbital_filling'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A neutral transition metal has the ground-state electron configuration [Ar]4s²3d^{{a}}. The argon core ([Ar]) contains 18 electrons. How many total electrons does this atom have?","params":{"a":{"min":1,"max":10,"step":1}},"answer_formula":"20 + a","precision":0,"unit":"electrons","distractors":[{"formula":"18 + a","error_type":"forgot_to_include_the_4s2_electrons_when_adding_to_the_argon_core"},{"formula":"10 + a","error_type":"used_neon_core_count_instead_of_argon_core_for_inner_electrons"},{"formula":"a + 2","error_type":"counted_only_3d_and_4s2_electrons_omitting_the_argon_core_entirely"}]}'::jsonb,
    'b086f18fefcfd1487dd4155e2530ae3a3b5b31993d79b406ce92bf3c56dad8d8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'mc_numeric',
    'hard',
    ARRAY['electronegativity','bond_dipole','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The electronegativity difference between two bonded atoms A and B is {{a}} units. A second bond between atoms C and D has an electronegativity difference of {{b}} units (where {{b}} > {{a}}). Which bond has the greater ionic character?","params":{"a":{"min":0.5,"max":1.5,"step":0.5},"b":{"min":2,"max":3.5,"step":0.5}},"answer_formula":"b","precision":1,"unit":"units (electronegativity difference of the more ionic bond)","distractors":[{"formula":"a","error_type":"chose_bond_with_smaller_electronegativity_difference"},{"formula":"b + a","error_type":"summed_the_two_electronegativity_differences_instead_of_identifying_the_larger"},{"formula":"(a + b) / 2","error_type":"averaged_the_two_differences_instead_of_identifying_the_larger"}]}'::jsonb,
    '773dfb9f28bd1ce391397992371dc33a506f636dfd9c0247ad3cba80e88287e8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'mc_numeric',
    'hard',
    ARRAY['ionization_energy','energy_ratio','shell_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An element''s 2nd ionization energy is {{a}} kJ/mol and its 3rd ionization energy is {{b}} kJ/mol. What is the ratio IE₃ / IE₂ for this element? This ratio helps identify dramatic jumps that reveal when a core electron is being removed.","params":{"a":{"min":1000,"max":3000,"step":500},"b":{"min":4000,"max":9000,"step":500}},"answer_formula":"b / a","precision":2,"unit":"","distractors":[{"formula":"a / b","error_type":"inverted_the_ratio_dividing_IE2_by_IE3"},{"formula":"b - a","error_type":"subtracted_instead_of_dividing"},{"formula":"b / (a + b)","error_type":"divided_IE3_by_the_sum_of_IE2_plus_IE3_instead_of_computing_the_ratio"}]}'::jsonb,
    '65d3b424c41c4fc76090b998375989b873436d4ff9063a1773aeffc5c93e6679'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'mc_numeric',
    'medium',
    ARRAY['ionic_radius','isoelectronic','nuclear_charge'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Two isoelectronic ions each have 10 electrons. Ion X has nuclear charge {{a}} and Ion Y has nuclear charge {{b}} (where {{b}} > {{a}}). Which ion has the smaller radius, and by how much does the nuclear charge differ? (Answer: report the larger nuclear charge, which corresponds to the smaller ion.)","params":{"a":{"min":8,"max":10,"step":1},"b":{"min":11,"max":13,"step":1}},"answer_formula":"b","precision":0,"unit":"(atomic number of smaller ion)","distractors":[{"formula":"a","error_type":"chose_lower_nuclear_charge_ion_which_is_actually_the_larger_ion"},{"formula":"b - a","error_type":"reported_the_difference_in_nuclear_charges_instead_of_identifying_the_ion"},{"formula":"a + b","error_type":"summed_both_nuclear_charges_instead_of_identifying_the_larger_one"}]}'::jsonb,
    '5e75ecb6df1ff2ffc5b27effdd8b9b8f915d1deefa02affbde09b71800297b5e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'fr_static',
    'easy',
    ARRAY['shielding','core_electrons','effective_nuclear_charge'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What term describes the phenomenon by which inner (core) electrons reduce the full attractive force of the nucleus felt by outer (valence) electrons?","accepted_answers":["shielding","electron shielding","screening","electron screening"],"semantic_fallback":true}'::jsonb,
    '778c603a5281b662a395778a3d1944fbe1b085647c5e6a4e226c69c9d963939e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Configuration (Advanced)',
    'fr_static',
    'easy',
    ARRAY['electron_configuration','aufbau_principle','subshell_order'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"State the principle that says electrons fill atomic orbitals in order of increasing energy, from lowest to highest, when building up the ground-state electron configuration of an atom.","accepted_answers":["aufbau principle","aufbau","building-up principle","building up principle"],"semantic_fallback":true}'::jsonb,
    '06c87dccea9829414810a10745fef6ba4af9c27170e55286e3a5199e7dc1e449'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'fr_static',
    'medium',
    ARRAY['ionization_energy','definition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What term describes the minimum energy required to remove the most loosely held electron from a gaseous neutral atom in its ground state?","accepted_answers":["first ionization energy","ionization energy","first ionization potential","ie1"],"semantic_fallback":true}'::jsonb,
    'ef1d75e5d52f3b1daf7b2cde5514d81d841d2695aeb12296f24b8f902a4341a1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'fr_static',
    'medium',
    ARRAY['electron_affinity','definition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What term describes the energy change that occurs when a neutral gaseous atom gains one electron to form a gaseous anion?","accepted_answers":["electron affinity","electron affinity energy"],"semantic_fallback":true}'::jsonb,
    '98f274eee582a98f99641542b0be4c5c77df9d82ea77a2d770b9ff119866e841'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Atomic and Ionic Radius Trends',
    'fr_static',
    'medium',
    ARRAY['isoelectronic','ionic_radius','periodic_trends'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What word describes a series of atoms or ions that all have the same number of electrons, such as O²⁻, F⁻, Na⁺, and Mg²⁺?","accepted_answers":["isoelectronic","isoelectronic series"],"semantic_fallback":true}'::jsonb,
    '1df7ea1955362d1606724f6203c2b71dff43888694426c3d210936598493137b'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Coulomb''s Law and Atomic Structure',
    'fr_static',
    'hard',
    ARRAY['coulombs_law','lattice_energy','ionic_radius'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Using Coulomb''s law, identify two factors that would each independently increase the strength of the electrostatic attraction between a cation and an anion in an ionic compound.","accepted_answers":["larger ionic charges and smaller ionic radii","higher charges and smaller distance between ions","greater magnitude of charges and smaller ionic radii","increasing ionic charges and decreasing ionic radii"],"semantic_fallback":true}'::jsonb,
    '4bf1a215c543b062b63c8a28f1b48f541e3d74f123338ccfd6a91e4c15d18406'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Ionization Energy (Successive)',
    'fr_numeric',
    'medium',
    ARRAY['ionization_energy','successive_ie','group_identification'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The successive ionization energies of element Q show a large jump between the {{a}}th and the ({{a}}+1)th ionization. In what group of the periodic table is element Q located?","params":{"a":{"min":1,"max":4,"step":1}},"answer_formula":"a","precision":0,"unit":"(Group number)","tolerance":0,"semantic_fallback":false}'::jsonb,
    'aed7eb5d37b27f49198961c0c956a57f0f2c5e6daae7e5d90299d85bf3fe91a7'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Shielding and Effective Nuclear Charge',
    'fr_numeric',
    'medium',
    ARRAY['effective_nuclear_charge','shielding','simplified_model'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Using the simplified model Z_eff ≈ Z − S (where Z = atomic number, S = number of core electrons), calculate the effective nuclear charge experienced by the valence electrons of phosphorus (P, Z = 15). Phosphorus has 10 core electrons.","params":{"a":{"min":1,"max":1,"step":1}},"answer_formula":"5 * a","precision":0,"unit":"","tolerance":0,"semantic_fallback":false}'::jsonb,
    '749b19b87139c424c116293c65d210b59e23c8b9febf15f60810d110cd943d92'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 1: Atomic Structure and Properties',
    9,
    'Electron Affinity and Electronegativity',
    'mc_numeric',
    'easy',
    ARRAY['electronegativity','periodic_trends','group_trend'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Electronegativity decreases going down a group. If element X in Period 2 has electronegativity {{a}} and each period down the group decreases electronegativity by {{b}} units, what is the electronegativity of the element {{a}} periods below X in the same group?","params":{"a":{"min":2.5,"max":4,"step":0.5},"b":{"min":0.3,"max":0.6,"step":0.1}},"answer_formula":"a - a * b","precision":2,"unit":"(Pauling units)","distractors":[{"formula":"a + a * b","error_type":"added_decrease_instead_of_subtracting_it"},{"formula":"a - 2 * b","error_type":"subtracted_twice_the_per_period_decrease_instead_of_scaling_by_number_of_periods"},{"formula":"a - b","error_type":"subtracted_one_step_decrease_instead_of_scaling_by_number_of_periods"}]}'::jsonb,
    '4d235b3c0b213b47745af7cfad98d7b9d0f40067aba0c35c2d12d0442864d34d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'easy',
    ARRAY['ionic_bond','covalent_bond','electronegativity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best describes the general rule for classifying a bond as ionic versus covalent?","options":["Bonds between a metal and a nonmetal are generally ionic; bonds between two nonmetals are generally covalent.","Bonds between two atoms of different masses are ionic; bonds between atoms of the same mass are covalent.","Bonds between large atoms are ionic; bonds between small atoms are covalent.","Bonds that release heat when formed are ionic; bonds that absorb heat are covalent."],"correct_index":0}'::jsonb,
    'bc62d0241e9de1c77cf86904a0dd76d0fe14db741f86b15c4a315f4445c29766'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes the general rule for classifying a bond as ionic versus covalent?', ARRAY['Bonds between a metal and a nonmetal are generally ionic; bonds between two nonmetals are generally covalent.','Bonds between two atoms of different masses are ionic; bonds between atoms of the same mass are covalent.','Bonds between large atoms are ionic; bonds between small atoms are covalent.','Bonds that release heat when formed are ionic; bonds that absorb heat are covalent.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'easy',
    ARRAY['polar_covalent_bond','electronegativity','bond_polarity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a polar covalent bond between atoms X and Y, where X is more electronegative than Y, which atom develops a partial negative charge?","options":["Atom X, because its higher electronegativity causes it to attract the shared electrons more strongly.","Atom Y, because the less electronegative atom must give up electron density.","Both atoms equally, because the bond is still covalent.","Neither atom; partial charges only occur in ionic bonds."],"correct_index":0}'::jsonb,
    '1844eb151dd38f6146094c1dfedb34762e6d9f0b6f8d9aff909c3ca817882fc4'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In a polar covalent bond between atoms X and Y, where X is more electronegative than Y, which atom develops a partial negative charge?', ARRAY['Atom X, because its higher electronegativity causes it to attract the shared electrons more strongly.','Atom Y, because the less electronegative atom must give up electron density.','Both atoms equally, because the bond is still covalent.','Neither atom; partial charges only occur in ionic bonds.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'easy',
    ARRAY['metallic_bonding','delocalized_electrons','sea_of_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best describes metallic bonding?","options":["An array of positive metal ion cores surrounded by delocalized valence electrons shared throughout the entire metal lattice.","Pairs of electrons localized between adjacent metal atoms, forming discrete bonds.","Alternating cations and anions arranged in a three-dimensional lattice held together by electrostatic attractions.","Molecules held together by induced dipole interactions in a regular crystal array."],"correct_index":0}'::jsonb,
    'e902418e86ae71af21ca03d8753075f6d15678b4cd1eff3301d2b0225d151691'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes metallic bonding?', ARRAY['An array of positive metal ion cores surrounded by delocalized valence electrons shared throughout the entire metal lattice.','Pairs of electrons localized between adjacent metal atoms, forming discrete bonds.','Alternating cations and anions arranged in a three-dimensional lattice held together by electrostatic attractions.','Molecules held together by induced dipole interactions in a regular crystal array.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'medium',
    ARRAY['bond_type_prediction','electronegativity','continuum'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following statements about the ionic-covalent bonding continuum is correct according to the AP Chemistry curriculum?","options":["All polar covalent bonds have some ionic character, and the boundary between ionic and covalent bonding is not distinct but is a continuum.","A bond is either purely ionic or purely covalent; there is no intermediate bond type.","A bond is classified as ionic only when the electronegativity difference is exactly 1.7.","Covalent bonds can never have any ionic character regardless of the electronegativity difference."],"correct_index":0}'::jsonb,
    '7f5bc98a6dc226b3d2d20a1d558617433bffaba2dd3b3f683b504b3d67ccff8a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following statements about the ionic-covalent bonding continuum is correct according to the AP Chemistry curriculum?', ARRAY['All polar covalent bonds have some ionic character, and the boundary between ionic and covalent bonding is not distinct but is a continuum.','A bond is either purely ionic or purely covalent; there is no intermediate bond type.','A bond is classified as ionic only when the electronegativity difference is exactly 1.7.','Covalent bonds can never have any ionic character regardless of the electronegativity difference.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'medium',
    ARRAY['nonpolar_covalent','electronegativity','bond_type'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following bonds is best classified as nonpolar covalent?","options":["C–H, because carbon and hydrogen have very similar electronegativities.","H–F, because fluorine has the highest electronegativity of all elements.","Na–Cl, because sodium and chlorine are in the same period.","O–H, because oxygen and hydrogen are both nonmetals."],"correct_index":0}'::jsonb,
    '8bddb21dd553bba57ac7728a04f243c6674c20a9ac1f55540fa7ab7bd8074dbe'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following bonds is best classified as nonpolar covalent?', ARRAY['C–H, because carbon and hydrogen have very similar electronegativities.','H–F, because fluorine has the highest electronegativity of all elements.','Na–Cl, because sodium and chlorine are in the same period.','O–H, because oxygen and hydrogen are both nonmetals.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_static',
    'hard',
    ARRAY['bond_type_prediction','properties','ionic_vs_covalent'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A student has two unknown compounds. Compound A dissolves in water and conducts electricity as a solution; Compound B does not conduct electricity in solution and has a low melting point. Which conclusion is best supported by these observations?","options":["Compound A is ionic and Compound B is molecular (covalent), because ionic compounds dissociate into ions in solution while molecular compounds do not.","Compound A is covalent and Compound B is ionic, because low melting points indicate stronger bonds.","Both compounds are ionic; the difference in conductivity reflects different ion concentrations.","Both compounds are covalent; the conductivity of Compound A is due to delocalized electrons."],"correct_index":0}'::jsonb,
    'f2f50cb13c74524916d1278498af372a1d14c42a6e6d9b1891474bdadc934b82'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A student has two unknown compounds. Compound A dissolves in water and conducts electricity as a solution; Compound B does not conduct electricity in solution and has a low melting point. Which conclusion is best supported by these observations?', ARRAY['Compound A is ionic and Compound B is molecular (covalent), because ionic compounds dissociate into ions in solution while molecular compounds do not.','Compound A is covalent and Compound B is ionic, because low melting points indicate stronger bonds.','Both compounds are ionic; the difference in conductivity reflects different ion concentrations.','Both compounds are covalent; the conductivity of Compound A is due to delocalized electrons.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_static',
    'easy',
    ARRAY['potential_energy_curve','bond_length','bond_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"On a potential energy vs. internuclear distance graph for a diatomic molecule, what does the minimum point on the curve represent?","options":["The equilibrium bond length, where the potential energy is lowest and the attractive and repulsive forces are balanced.","The point at which the molecule has its highest kinetic energy.","The bond dissociation energy, which is the energy required to break the bond.","The point at which repulsive forces become zero."],"correct_index":0}'::jsonb,
    'de13833dc8185194fdbababe6f79fa73bf79f019c2e7796510e93c654efcf7b0'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'On a potential energy vs. internuclear distance graph for a diatomic molecule, what does the minimum point on the curve represent?', ARRAY['The equilibrium bond length, where the potential energy is lowest and the attractive and repulsive forces are balanced.','The point at which the molecule has its highest kinetic energy.','The bond dissociation energy, which is the energy required to break the bond.','The point at which repulsive forces become zero.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_static',
    'medium',
    ARRAY['bond_order','bond_length','bond_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly ranks the C–C, C=C, and C≡C bonds in order of increasing bond length (shortest to longest)?","options":["C≡C < C=C < C–C","C–C < C=C < C≡C","C=C < C–C < C≡C","C≡C < C–C < C=C"],"correct_index":0}'::jsonb,
    'b6d6da836c96a9a6bb6e96dfdaf68c6a12cec80c12d26134c5afb5884e79d37c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly ranks the C–C, C=C, and C≡C bonds in order of increasing bond length (shortest to longest)?', ARRAY['C≡C < C=C < C–C','C–C < C=C < C≡C','C=C < C–C < C≡C','C≡C < C–C < C=C'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_static',
    'medium',
    ARRAY['bond_order','bond_energy','bond_length'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly states the relationship between bond order, bond energy, and bond length?","options":["Higher bond order → shorter bond length and greater bond energy.","Higher bond order → longer bond length and greater bond energy.","Higher bond order → shorter bond length and lower bond energy.","Higher bond order → longer bond length and lower bond energy."],"correct_index":0}'::jsonb,
    'd4892474bec9d6c8cde5073bdcbecfed67295b315e3072371b05ecbd09c67a26'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly states the relationship between bond order, bond energy, and bond length?', ARRAY['Higher bond order → shorter bond length and greater bond energy.','Higher bond order → longer bond length and greater bond energy.','Higher bond order → shorter bond length and lower bond energy.','Higher bond order → longer bond length and lower bond energy.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_static',
    'hard',
    ARRAY['potential_energy_curve','ionic_interaction','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Two ionic compounds, LiF and CsI, are compared. Based on the potential energy vs. internuclear distance model and Coulomb''s law, which compound has a deeper potential energy well (lower minimum energy) and why?","options":["LiF, because Li⁺ and F⁻ are smaller ions so the distance between ion centers is shorter, producing stronger electrostatic attraction per Coulomb''s law.","CsI, because Cs⁺ and I⁻ are larger ions that can hold more electrons and thus attract each other more strongly.","LiF, because lithium has a lower mass than cesium, making its bonds inherently stronger.","CsI, because larger ions are more polarizable and experience greater London dispersion forces."],"correct_index":0}'::jsonb,
    'c05300edd5884c2f6929c9c25dfb00f5baf3a15d7647952fd0feac96881e3c0a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Two ionic compounds, LiF and CsI, are compared. Based on the potential energy vs. internuclear distance model and Coulomb''s law, which compound has a deeper potential energy well (lower minimum energy) and why?', ARRAY['LiF, because Li⁺ and F⁻ are smaller ions so the distance between ion centers is shorter, producing stronger electrostatic attraction per Coulomb''s law.','CsI, because Cs⁺ and I⁻ are larger ions that can hold more electrons and thus attract each other more strongly.','LiF, because lithium has a lower mass than cesium, making its bonds inherently stronger.','CsI, because larger ions are more polarizable and experience greater London dispersion forces.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_static',
    'easy',
    ARRAY['ionic_solid','crystal_lattice','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In an ionic crystal, how are the cations and anions arranged?","options":["In a systematic, periodic 3-D array that maximizes attractive forces between oppositely charged ions while minimizing repulsive forces between like-charged ions.","Randomly distributed throughout the solid with no long-range order.","In discrete neutral ion pairs arranged in a loose lattice.","In separate layers, with all cations in one layer and all anions in another."],"correct_index":0}'::jsonb,
    '2db0252aca24f52a5e3c758602e7ed5cfa9dd6da7c4f7a311581f0d9f6d1fe9c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In an ionic crystal, how are the cations and anions arranged?', ARRAY['In a systematic, periodic 3-D array that maximizes attractive forces between oppositely charged ions while minimizing repulsive forces between like-charged ions.','Randomly distributed throughout the solid with no long-range order.','In discrete neutral ion pairs arranged in a loose lattice.','In separate layers, with all cations in one layer and all anions in another.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_static',
    'medium',
    ARRAY['lattice_energy','coulombs_law','ionic_charge','ionic_radius'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following ionic compounds is predicted to have the highest lattice energy?","options":["MgO, because it has doubly charged ions (Mg²⁺ and O²⁻) and small ionic radii.","KBr, because potassium and bromine are in the same period of the periodic table.","NaCl, because it is the most common ionic compound and has well-studied properties.","CsF, because fluorine has the highest electronegativity."],"correct_index":0}'::jsonb,
    'fb0a9243b15ddebfc771a45385b4daf544cda333df3fbaa37cc2ed7cac4eb922'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following ionic compounds is predicted to have the highest lattice energy?', ARRAY['MgO, because it has doubly charged ions (Mg²⁺ and O²⁻) and small ionic radii.','KBr, because potassium and bromine are in the same period of the periodic table.','NaCl, because it is the most common ionic compound and has well-studied properties.','CsF, because fluorine has the highest electronegativity.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_static',
    'medium',
    ARRAY['ionic_solid','brittleness','properties'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Ionic crystals are typically brittle. Which of the following best explains this property at the particulate level?","options":["When an ionic crystal is struck, ions shift so that like charges align, creating strong repulsive forces that cause the crystal to fracture along planes.","Ionic crystals have delocalized electrons that allow cracks to propagate easily through the material.","The covalent bonds between ions in the lattice are too rigid to accommodate any mechanical stress.","Ionic crystals dissolve easily in water, which weakens their internal structure under mechanical stress."],"correct_index":0}'::jsonb,
    '5b5be9926de756c7cd9b0f9c077822841adfc43843081a057524f7662cfd137d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Ionic crystals are typically brittle. Which of the following best explains this property at the particulate level?', ARRAY['When an ionic crystal is struck, ions shift so that like charges align, creating strong repulsive forces that cause the crystal to fracture along planes.','Ionic crystals have delocalized electrons that allow cracks to propagate easily through the material.','The covalent bonds between ions in the lattice are too rigid to accommodate any mechanical stress.','Ionic crystals dissolve easily in water, which weakens their internal structure under mechanical stress.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_static',
    'hard',
    ARRAY['lattice_energy','ionic_radius','charge','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best explains why CaO has a higher melting point than KF, even though both are ionic compounds with a 1:1 cation:anion ratio?","options":["Ca²⁺ and O²⁻ have charges of ±2, producing much stronger electrostatic attractions than K⁺ and F⁻ with charges of ±1, and the smaller Ca²⁺ and O²⁻ ions reduce the interionic distance further.","CaO has a more symmetric crystal structure than KF, which increases its melting point.","Calcium has a higher atomic mass than potassium, requiring more energy to break the lattice.","Oxygen is more electronegative than fluorine, forming stronger ionic bonds with calcium."],"correct_index":0}'::jsonb,
    '613c4f7e05fa3a2591e862157e20579194652fa9903178eb535fd51e2765f9f8'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best explains why CaO has a higher melting point than KF, even though both are ionic compounds with a 1:1 cation:anion ratio?', ARRAY['Ca²⁺ and O²⁻ have charges of ±2, producing much stronger electrostatic attractions than K⁺ and F⁻ with charges of ±1, and the smaller Ca²⁺ and O²⁻ ions reduce the interionic distance further.','CaO has a more symmetric crystal structure than KF, which increases its melting point.','Calcium has a higher atomic mass than potassium, requiring more energy to break the lattice.','Oxygen is more electronegative than fluorine, forming stronger ionic bonds with calcium.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Metals and Alloys',
    'mc_static',
    'easy',
    ARRAY['metallic_bonding','malleability','conductivity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which macroscopic property of metals is best explained by the presence of delocalized valence electrons (the ''sea of electrons'' model)?","options":["Electrical conductivity, because delocalized electrons can move freely through the metal in response to a voltage.","High melting point, because delocalized electrons prevent atoms from vibrating.","Chemical inertness, because delocalized electrons shield the metal ions from reactions.","Brittleness, because delocalized electrons create rigid bonds between metal ions."],"correct_index":0}'::jsonb,
    '50e14ebfe28b0c2ce420dc2eb2af6be81c77e5381821b75eb2e2325eb43849ef'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which macroscopic property of metals is best explained by the presence of delocalized valence electrons (the ''sea of electrons'' model)?', ARRAY['Electrical conductivity, because delocalized electrons can move freely through the metal in response to a voltage.','High melting point, because delocalized electrons prevent atoms from vibrating.','Chemical inertness, because delocalized electrons shield the metal ions from reactions.','Brittleness, because delocalized electrons create rigid bonds between metal ions.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Metals and Alloys',
    'mc_static',
    'medium',
    ARRAY['alloys','interstitial_alloy','substitutional_alloy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Steel is an alloy of iron and carbon. What type of alloy is steel, and what structural feature classifies it as this type?","options":["Interstitial alloy, because carbon atoms are much smaller than iron atoms and occupy the spaces between iron atoms in the lattice.","Substitutional alloy, because carbon atoms replace iron atoms at lattice sites.","Interstitial alloy, because carbon and iron have nearly identical atomic radii.","Substitutional alloy, because carbon atoms are distributed randomly throughout the iron lattice."],"correct_index":0}'::jsonb,
    'e72cdc702f5a08146d0b02cfafad69e065ef45adb90adaa6fb88041ed604807c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Steel is an alloy of iron and carbon. What type of alloy is steel, and what structural feature classifies it as this type?', ARRAY['Interstitial alloy, because carbon atoms are much smaller than iron atoms and occupy the spaces between iron atoms in the lattice.','Substitutional alloy, because carbon atoms replace iron atoms at lattice sites.','Interstitial alloy, because carbon and iron have nearly identical atomic radii.','Substitutional alloy, because carbon atoms are distributed randomly throughout the iron lattice.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Metals and Alloys',
    'mc_static',
    'medium',
    ARRAY['alloys','substitutional_alloy','atomic_radius'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Brass is an alloy composed of copper and zinc. Given that copper and zinc have similar atomic radii, what type of alloy is brass?","options":["Substitutional alloy, because zinc atoms substitute for copper atoms at lattice positions due to their comparable atomic radii.","Interstitial alloy, because zinc atoms fit into the spaces between copper atoms.","Substitutional alloy, because zinc and copper are both transition metals.","Interstitial alloy, because zinc is slightly larger than copper and distorts the lattice."],"correct_index":0}'::jsonb,
    '04e088db1ccbf0b660242da2b409fc811455fa806f4e1ba56046fa501c530f37'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Brass is an alloy composed of copper and zinc. Given that copper and zinc have similar atomic radii, what type of alloy is brass?', ARRAY['Substitutional alloy, because zinc atoms substitute for copper atoms at lattice positions due to their comparable atomic radii.','Interstitial alloy, because zinc atoms fit into the spaces between copper atoms.','Substitutional alloy, because zinc and copper are both transition metals.','Interstitial alloy, because zinc is slightly larger than copper and distorts the lattice.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Metals and Alloys',
    'mc_static',
    'hard',
    ARRAY['alloys','properties','metallic_bonding','interstitial_alloy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Adding carbon to iron to make steel significantly increases the hardness and tensile strength of the metal. Which of the following best explains this observation at the particulate level?","options":["Carbon atoms in the interstitial positions of the iron lattice impede the sliding of iron atom layers past one another, resisting deformation.","Carbon atoms replace iron atoms and form stronger covalent bonds with neighboring iron atoms.","The added carbon increases the density of delocalized electrons, strengthening metallic bonds.","Carbon forms a separate ionic layer between iron layers, which locks the layers in place."],"correct_index":0}'::jsonb,
    'bce9126207c5ee5605a9361c0606031dbe664fd53eb295ea8f4eb2d3835a3c40'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Adding carbon to iron to make steel significantly increases the hardness and tensile strength of the metal. Which of the following best explains this observation at the particulate level?', ARRAY['Carbon atoms in the interstitial positions of the iron lattice impede the sliding of iron atom layers past one another, resisting deformation.','Carbon atoms replace iron atoms and form stronger covalent bonds with neighboring iron atoms.','The added carbon increases the density of delocalized electrons, strengthening metallic bonds.','Carbon forms a separate ionic layer between iron layers, which locks the layers in place.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_static',
    'easy',
    ARRAY['lewis_structure','valence_electrons','octet_rule'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"O=C=O","caption":"Carbon dioxide (CO2)"}'::jsonb,
    '{"stem":"How many total valence electrons are used in the correct Lewis structure of CO₂?","options":["16 (C contributes 4, each O contributes 6)","12 (C contributes 4, each O contributes 4)","18 (C contributes 6, each O contributes 6)","8 (C contributes 4, each O contributes 2)"],"correct_index":0}'::jsonb,
    'cbcd626cab1bf75f6e6316f59e70ffb5129ca7f90792d7cc0ae8d9c8a6e2e7b3'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'How many total valence electrons are used in the correct Lewis structure of CO₂?', ARRAY['16 (C contributes 4, each O contributes 6)','12 (C contributes 4, each O contributes 4)','18 (C contributes 6, each O contributes 6)','8 (C contributes 4, each O contributes 2)'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_static',
    'easy',
    ARRAY['lewis_structure','lone_pairs','valence_electrons'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"N","caption":"Ammonia (NH3)"}'::jsonb,
    '{"stem":"In the correct Lewis structure of NH₃, how many lone pairs are on the nitrogen atom?","options":["1 lone pair","0 lone pairs","2 lone pairs","3 lone pairs"],"correct_index":0}'::jsonb,
    '643a01bdc009ebb838860cb88e7e11142783e8d8e4f8cf62b5d4505fa1057b42'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In the correct Lewis structure of NH₃, how many lone pairs are on the nitrogen atom?', ARRAY['1 lone pair','0 lone pairs','2 lone pairs','3 lone pairs'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_static',
    'medium',
    ARRAY['lewis_structure','expanded_octet','valence_electrons'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"FP(F)(F)(F)F","caption":"Phosphorus pentafluoride (PF5)"}'::jsonb,
    '{"stem":"How many total valence electrons are in the Lewis structure of PF₅, and does phosphorus obey the octet rule in this molecule?","options":["40 total valence electrons; phosphorus has 10 electrons around it (expanded octet).","32 total valence electrons; phosphorus obeys the octet rule with 8 electrons around it.","40 total valence electrons; phosphorus obeys the octet rule because P is in Period 3.","35 total valence electrons; phosphorus has an odd-electron structure."],"correct_index":0}'::jsonb,
    '8f17a1a333372feb0375afdb0aa2d631cafa05635919eae3f21c0a9de0e5b310'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'How many total valence electrons are in the Lewis structure of PF₅, and does phosphorus obey the octet rule in this molecule?', ARRAY['40 total valence electrons; phosphorus has 10 electrons around it (expanded octet).','32 total valence electrons; phosphorus obeys the octet rule with 8 electrons around it.','40 total valence electrons; phosphorus obeys the octet rule because P is in Period 3.','35 total valence electrons; phosphorus has an odd-electron structure.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_static',
    'medium',
    ARRAY['lewis_structure','polyatomic_ion','valence_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What is the total number of valence electrons used in the Lewis structure of the nitrate ion (NO₃⁻)?","options":["24 (N: 5, each O: 6 × 3 = 18, plus 1 for the negative charge)","23 (N: 5, each O: 6 × 3 = 18)","25 (N: 5, each O: 6 × 3 = 18, plus 2 for the negative charge)","22 (N: 4, each O: 6 × 3 = 18)"],"correct_index":0}'::jsonb,
    'd64f55edd63488d4e02389f1cdf367c2ff062b46a05214447017dd2921d1380d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the total number of valence electrons used in the Lewis structure of the nitrate ion (NO₃⁻)?', ARRAY['24 (N: 5, each O: 6 × 3 = 18, plus 1 for the negative charge)','23 (N: 5, each O: 6 × 3 = 18)','25 (N: 5, each O: 6 × 3 = 18, plus 2 for the negative charge)','22 (N: 4, each O: 6 × 3 = 18)'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_static',
    'hard',
    ARRAY['lewis_structure','odd_electron','radical','limitations'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"[N]=O","caption":"Nitrogen monoxide (NO)"}'::jsonb,
    '{"stem":"Which of the following best describes a limitation of the Lewis structure model as applied to nitrogen monoxide (NO)?","options":["NO has 11 valence electrons (an odd number), so no Lewis structure can be drawn that gives both atoms a full octet; the Lewis model cannot accurately represent odd-electron species.","NO cannot form a Lewis structure because nitrogen and oxygen are both nonmetals.","NO violates the Lewis model because the bond between N and O is purely ionic.","The Lewis structure of NO requires d-orbital involvement, which the model does not support."],"correct_index":0}'::jsonb,
    '08922ab750de452fbaa9bd417821d90292197568f14af74a9e6350f4a9c19fce'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes a limitation of the Lewis structure model as applied to nitrogen monoxide (NO)?', ARRAY['NO has 11 valence electrons (an odd number), so no Lewis structure can be drawn that gives both atoms a full octet; the Lewis model cannot accurately represent odd-electron species.','NO cannot form a Lewis structure because nitrogen and oxygen are both nonmetals.','NO violates the Lewis model because the bond between N and O is purely ionic.','The Lewis structure of NO requires d-orbital involvement, which the model does not support.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_static',
    'easy',
    ARRAY['resonance','delocalization','equivalent_structures'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"[O-][N+](=O)[O-]","caption":"Nitrate ion (NO3-)"}'::jsonb,
    '{"stem":"Which of the following best describes why resonance structures are used for the nitrate ion (NO₃⁻)?","options":["All three N–O bonds in NO₃⁻ are experimentally identical in length and energy, so no single Lewis structure adequately represents the molecule; resonance shows the electron density is delocalized.","The nitrate ion rapidly switches between three distinct structures, spending equal time in each.","Resonance structures are used because the octet rule cannot be satisfied for nitrogen in NO₃⁻.","Each resonance structure represents a different isotope of nitrogen."],"correct_index":0}'::jsonb,
    'cb085ab56c57305a3cfa0d0ed22e9fd17bb8b92e92bb96d38273ae9805b9e30b'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes why resonance structures are used for the nitrate ion (NO₃⁻)?', ARRAY['All three N–O bonds in NO₃⁻ are experimentally identical in length and energy, so no single Lewis structure adequately represents the molecule; resonance shows the electron density is delocalized.','The nitrate ion rapidly switches between three distinct structures, spending equal time in each.','Resonance structures are used because the octet rule cannot be satisfied for nitrogen in NO₃⁻.','Each resonance structure represents a different isotope of nitrogen.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_static',
    'medium',
    ARRAY['formal_charge','lewis_structure','best_structure'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"O=C=O","caption":"Carbon dioxide (CO2)"}'::jsonb,
    '{"stem":"The formal charge on carbon in the correct Lewis structure of CO₂ (O=C=O) is calculated as: FC = (valence electrons) − (lone pair electrons) − ½(bonding electrons). What is the formal charge on carbon?","options":["0 (FC = 4 − 0 − ½(8) = 0)","+2 (FC = 4 − 0 − 4 = 0 is wrong; carbon has +2)","−2 (FC = 4 − 4 − 4 = −4, adjusted)","+4 (FC = 4 − 0 − 0 = 4)"],"correct_index":0}'::jsonb,
    'a1cb3072085fcdafed832a10ec4607a10730e57466f773668ac3ac81f082822e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The formal charge on carbon in the correct Lewis structure of CO₂ (O=C=O) is calculated as: FC = (valence electrons) − (lone pair electrons) − ½(bonding electrons). What is the formal charge on carbon?', ARRAY['0 (FC = 4 − 0 − ½(8) = 0)','+2 (FC = 4 − 0 − 4 = 0 is wrong; carbon has +2)','−2 (FC = 4 − 4 − 4 = −4, adjusted)','+4 (FC = 4 − 0 − 0 = 4)'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_static',
    'medium',
    ARRAY['formal_charge','best_lewis_structure','octet_rule'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"S=O","caption":"Sulfur dioxide (SO2) - representative structure"}'::jsonb,
    '{"stem":"Two possible Lewis structures for SO₂ can be drawn: one with a single bond between S and one O and a double bond to the other O, and one where both S–O bonds are equivalent (resonance). Which criterion is used to determine that neither single structure is the best model?","options":["The experimental observation that both S–O bonds are identical in length and energy indicates delocalization, making resonance the better model.","The formal charge on sulfur is zero in both structures, so either one is acceptable.","The structure with two double bonds is preferred because it gives sulfur a lower formal charge.","The Lewis structure with the most lone pairs on the central atom is always preferred."],"correct_index":0}'::jsonb,
    '2ac0b785325414e9ffff2ae455260429cec419def90af4682079f0bcda9b799d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Two possible Lewis structures for SO₂ can be drawn: one with a single bond between S and one O and a double bond to the other O, and one where both S–O bonds are equivalent (resonance). Which criterion is used to determine that neither single structure is the best model?', ARRAY['The experimental observation that both S–O bonds are identical in length and energy indicates delocalization, making resonance the better model.','The formal charge on sulfur is zero in both structures, so either one is acceptable.','The structure with two double bonds is preferred because it gives sulfur a lower formal charge.','The Lewis structure with the most lone pairs on the central atom is always preferred.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_static',
    'hard',
    ARRAY['formal_charge','resonance','best_lewis_structure'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Two Lewis structures for SCN⁻ are proposed: Structure A has S=C=N⁻ (double bonds on each side of C) and Structure B has ⁻S–C≡N. Using formal charge, which is the preferred structure and why?","options":["Structure B (⁻S–C≡N) is preferred because formal charges are closer to zero on C and N (FC on C = 0, N = 0, S = −1), minimizing formal charge separation.","Structure A is preferred because both double bonds distribute charge equally across all atoms.","Structure B is preferred because sulfur always carries a triple bond in thiocyanate.","Neither structure is valid because SCN⁻ cannot be represented by Lewis structures."],"correct_index":0}'::jsonb,
    '29ff39f301ac968cbeddca954b170d2bd062627aa27fe2fad88cbb495f1d40ca'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Two Lewis structures for SCN⁻ are proposed: Structure A has S=C=N⁻ (double bonds on each side of C) and Structure B has ⁻S–C≡N. Using formal charge, which is the preferred structure and why?', ARRAY['Structure B (⁻S–C≡N) is preferred because formal charges are closer to zero on C and N (FC on C = 0, N = 0, S = −1), minimizing formal charge separation.','Structure A is preferred because both double bonds distribute charge equally across all atoms.','Structure B is preferred because sulfur always carries a triple bond in thiocyanate.','Neither structure is valid because SCN⁻ cannot be represented by Lewis structures.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'easy',
    ARRAY['vsepr','molecular_geometry','electron_geometry'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"O","caption":"Water (H2O)"}'::jsonb,
    '{"stem":"What is the molecular geometry of water (H₂O)?","options":["Bent, because oxygen has 2 bonding pairs and 2 lone pairs, and lone pairs compress the bond angle below 109.5°.","Linear, because the two hydrogen atoms are on opposite sides of the oxygen.","Tetrahedral, because oxygen has four electron groups around it.","Trigonal planar, because oxygen has three electron groups."],"correct_index":0}'::jsonb,
    'd25237d57ab302fa8283ab4582b0d951e1e38c041468d8ae4fbfa492ff647277'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the molecular geometry of water (H₂O)?', ARRAY['Bent, because oxygen has 2 bonding pairs and 2 lone pairs, and lone pairs compress the bond angle below 109.5°.','Linear, because the two hydrogen atoms are on opposite sides of the oxygen.','Tetrahedral, because oxygen has four electron groups around it.','Trigonal planar, because oxygen has three electron groups.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'easy',
    ARRAY['vsepr','molecular_geometry','linear'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"O=C=O","caption":"Carbon dioxide (CO2)"}'::jsonb,
    '{"stem":"What is the molecular geometry of CO₂?","options":["Linear, because carbon has 2 bonding groups and no lone pairs, giving 180° bond angles.","Bent, because the double bonds create lone-pair-like repulsion.","Trigonal planar, because carbon has three electron groups.","Tetrahedral, because each double bond counts as two electron pairs."],"correct_index":0}'::jsonb,
    '3d54a2a55b9323d2fb025bdae78bb186370a2ca0d46fee86e2ecf9dc5b6827bb'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the molecular geometry of CO₂?', ARRAY['Linear, because carbon has 2 bonding groups and no lone pairs, giving 180° bond angles.','Bent, because the double bonds create lone-pair-like repulsion.','Trigonal planar, because carbon has three electron groups.','Tetrahedral, because each double bond counts as two electron pairs.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'medium',
    ARRAY['vsepr','molecular_geometry','lone_pairs','bond_angle'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"N","caption":"Ammonia (NH3)"}'::jsonb,
    '{"stem":"The bond angle in NH₃ is approximately 107°, which is less than the ideal tetrahedral angle of 109.5°. Which of the following best explains this?","options":["The lone pair on nitrogen occupies more space than a bonding pair, compressing the H–N–H bond angles below 109.5°.","The three hydrogen atoms repel each other more strongly than they repel the lone pair.","Nitrogen uses sp² hybridization in NH₃, giving ideal bond angles of 120°.","The lone pair is located in a p orbital perpendicular to the molecular plane and has no effect on bond angles."],"correct_index":0}'::jsonb,
    '3730a9b4cfe0dd48b45d800f2242567ba3e86a86323f7c3875d6161201d0d8de'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'The bond angle in NH₃ is approximately 107°, which is less than the ideal tetrahedral angle of 109.5°. Which of the following best explains this?', ARRAY['The lone pair on nitrogen occupies more space than a bonding pair, compressing the H–N–H bond angles below 109.5°.','The three hydrogen atoms repel each other more strongly than they repel the lone pair.','Nitrogen uses sp² hybridization in NH₃, giving ideal bond angles of 120°.','The lone pair is located in a p orbital perpendicular to the molecular plane and has no effect on bond angles.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'medium',
    ARRAY['vsepr','molecular_geometry','trigonal_pyramidal'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"N","caption":"Ammonia (NH3)"}'::jsonb,
    '{"stem":"What is the correct electron geometry and molecular geometry of NH₃?","options":["Electron geometry: tetrahedral; molecular geometry: trigonal pyramidal.","Electron geometry: trigonal planar; molecular geometry: trigonal pyramidal.","Electron geometry: tetrahedral; molecular geometry: tetrahedral.","Electron geometry: trigonal pyramidal; molecular geometry: bent."],"correct_index":0}'::jsonb,
    'd9e8f15599a0da616e3cf6b22cb68bdd3ddd00013079b431c4b72338080b1ba1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the correct electron geometry and molecular geometry of NH₃?', ARRAY['Electron geometry: tetrahedral; molecular geometry: trigonal pyramidal.','Electron geometry: trigonal planar; molecular geometry: trigonal pyramidal.','Electron geometry: tetrahedral; molecular geometry: tetrahedral.','Electron geometry: trigonal pyramidal; molecular geometry: bent.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'medium',
    ARRAY['vsepr','molecular_geometry','trigonal_bipyramidal'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"FP(F)(F)(F)F","caption":"Phosphorus pentafluoride (PF5)"}'::jsonb,
    '{"stem":"What is the molecular geometry of PF₅?","options":["Trigonal bipyramidal, because phosphorus has 5 bonding pairs and 0 lone pairs.","Octahedral, because phosphorus is surrounded by 5 fluorine atoms.","Square pyramidal, because there are 5 bonding pairs arranged around phosphorus.","Trigonal planar, because the 5 bonds arrange in a flat plane around phosphorus."],"correct_index":0}'::jsonb,
    '8add6d73c7d455ae2fdf84c3f4e6fba1739587022722f29db82a3306c1c45344'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the molecular geometry of PF₅?', ARRAY['Trigonal bipyramidal, because phosphorus has 5 bonding pairs and 0 lone pairs.','Octahedral, because phosphorus is surrounded by 5 fluorine atoms.','Square pyramidal, because there are 5 bonding pairs arranged around phosphorus.','Trigonal planar, because the 5 bonds arrange in a flat plane around phosphorus.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'hard',
    ARRAY['vsepr','molecular_geometry','square_planar','lone_pairs'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"F[Xe](F)(F)F","caption":"Xenon tetrafluoride (XeF4)"}'::jsonb,
    '{"stem":"XeF₄ has 6 electron groups around xenon (4 bonding pairs and 2 lone pairs). What is the molecular geometry of XeF₄?","options":["Square planar, because the 2 lone pairs occupy axial positions opposite each other in an octahedral electron geometry, leaving the 4 F atoms in a square plane.","Octahedral, because xenon has 6 electron groups around it.","Seesaw, because the 2 lone pairs are in equatorial positions of a trigonal bipyramidal geometry.","Square pyramidal, because one lone pair is axial and the other is equatorial."],"correct_index":0}'::jsonb,
    '50c3b7149eee924a7adbfc623e9b0a884ed30f8ad97f780333c92307a5b6f83d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'XeF₄ has 6 electron groups around xenon (4 bonding pairs and 2 lone pairs). What is the molecular geometry of XeF₄?', ARRAY['Square planar, because the 2 lone pairs occupy axial positions opposite each other in an octahedral electron geometry, leaving the 4 F atoms in a square plane.','Octahedral, because xenon has 6 electron groups around it.','Seesaw, because the 2 lone pairs are in equatorial positions of a trigonal bipyramidal geometry.','Square pyramidal, because one lone pair is axial and the other is equatorial.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_static',
    'hard',
    ARRAY['vsepr','seesaw','lone_pairs','trigonal_bipyramidal'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"FS(F)(F)F","caption":"Sulfur tetrafluoride (SF4)"}'::jsonb,
    '{"stem":"SF₄ has 5 electron groups around sulfur (4 bonding pairs and 1 lone pair). The lone pair occupies an equatorial position in the trigonal bipyramidal electron geometry. What is the molecular geometry of SF₄?","options":["Seesaw (also called sawhorse or disphenoidal), because the lone pair in the equatorial position causes the axial F atoms to bend toward the equatorial F atoms.","Trigonal bipyramidal, because lone pairs are counted the same as bonding pairs in VSEPR.","Trigonal pyramidal, because there are 3 bonding pairs and 1 lone pair in the base.","Square planar, because sulfur has 4 fluorine atoms arranged symmetrically."],"correct_index":0}'::jsonb,
    'ce2f77f4c447df8d6baf7b6c91eea1fd48146160bfa5ab058579943615dd1223'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'SF₄ has 5 electron groups around sulfur (4 bonding pairs and 1 lone pair). The lone pair occupies an equatorial position in the trigonal bipyramidal electron geometry. What is the molecular geometry of SF₄?', ARRAY['Seesaw (also called sawhorse or disphenoidal), because the lone pair in the equatorial position causes the axial F atoms to bend toward the equatorial F atoms.','Trigonal bipyramidal, because lone pairs are counted the same as bonding pairs in VSEPR.','Trigonal pyramidal, because there are 3 bonding pairs and 1 lone pair in the base.','Square planar, because sulfur has 4 fluorine atoms arranged symmetrically.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'mc_static',
    'easy',
    ARRAY['hybridization','sp3','tetrahedral'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"C","caption":"Methane (CH4)"}'::jsonb,
    '{"stem":"What is the hybridization of the carbon atom in methane (CH₄), and what bond angle is associated with this hybridization?","options":["sp³ hybridization; 109.5° bond angles.","sp² hybridization; 120° bond angles.","sp hybridization; 180° bond angles.","sp³d hybridization; 90° and 120° bond angles."],"correct_index":0}'::jsonb,
    '36761e7bb6761f79135f307bd7b452d789c5bb593f015a7c999c9048caf7112d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'What is the hybridization of the carbon atom in methane (CH₄), and what bond angle is associated with this hybridization?', ARRAY['sp³ hybridization; 109.5° bond angles.','sp² hybridization; 120° bond angles.','sp hybridization; 180° bond angles.','sp³d hybridization; 90° and 120° bond angles.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'mc_static',
    'medium',
    ARRAY['hybridization','sp2','trigonal_planar','pi_bond'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"C=C","caption":"Ethylene (H2C=CH2)"}'::jsonb,
    '{"stem":"In ethylene (H₂C=CH₂), what hybridization do the carbon atoms have, and what types of bonds make up the C=C double bond?","options":["sp² hybridization; the double bond consists of one sigma bond (from sp² orbital overlap) and one pi bond (from unhybridized p orbital overlap).","sp³ hybridization; the double bond consists of two sigma bonds.","sp hybridization; the double bond consists of one sigma and one pi bond.","sp² hybridization; the double bond consists of two pi bonds."],"correct_index":0}'::jsonb,
    '8de3c2a36f931be36d597d9776188a4260210367b5966fe85c8238edf33178c3'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In ethylene (H₂C=CH₂), what hybridization do the carbon atoms have, and what types of bonds make up the C=C double bond?', ARRAY['sp² hybridization; the double bond consists of one sigma bond (from sp² orbital overlap) and one pi bond (from unhybridized p orbital overlap).','sp³ hybridization; the double bond consists of two sigma bonds.','sp hybridization; the double bond consists of one sigma and one pi bond.','sp² hybridization; the double bond consists of two pi bonds.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'mc_static',
    'medium',
    ARRAY['hybridization','sp','linear','triple_bond'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"C#N","caption":"Hydrogen cyanide (HCN)"}'::jsonb,
    '{"stem":"In hydrogen cyanide (HCN, written H–C≡N), what is the hybridization of carbon and nitrogen, and what is the bond angle at carbon?","options":["Both carbon and nitrogen are sp hybridized; bond angle at carbon is 180°.","Carbon is sp² and nitrogen is sp³; bond angle at carbon is 120°.","Both carbon and nitrogen are sp³ hybridized; bond angle at carbon is 109.5°.","Carbon is sp and nitrogen is sp²; bond angle at carbon is 180°."],"correct_index":0}'::jsonb,
    '7aed6bed7e8af11daedc8dde53eef641a0bd16f1151774e39a6eb03bab0ddb6a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In hydrogen cyanide (HCN, written H–C≡N), what is the hybridization of carbon and nitrogen, and what is the bond angle at carbon?', ARRAY['Both carbon and nitrogen are sp hybridized; bond angle at carbon is 180°.','Carbon is sp² and nitrogen is sp³; bond angle at carbon is 120°.','Both carbon and nitrogen are sp³ hybridized; bond angle at carbon is 109.5°.','Carbon is sp and nitrogen is sp²; bond angle at carbon is 180°.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'mc_static',
    'hard',
    ARRAY['hybridization','sigma_pi_bonds','geometric_isomers','pi_bond'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"C=C","caption":"Alkene C=C double bond (geometric isomers)"}'::jsonb,
    '{"stem":"Which of the following correctly explains why geometric (cis-trans) isomers exist for molecules with C=C double bonds but not for molecules with C–C single bonds?","options":["The pi bond in a C=C double bond prevents free rotation about the bond axis because rotating the pi bond would require breaking the sideways overlap of the p orbitals; the C–C single bond has only sigma bond overlap, allowing free rotation.","The C=C bond is shorter than the C–C bond, which locks the atoms in position.","The sp² hybridization of the C=C carbons makes the bonds rigid, whereas sp³ carbons in a C–C bond can rotate freely because they are tetrahedral.","C=C double bonds have greater bond energy than C–C single bonds, making rotation energetically impossible."],"correct_index":0}'::jsonb,
    'ff35ef718e1ae8c6022931f732096e43daeeabf17a13297ef01b04fb85e83f44'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly explains why geometric (cis-trans) isomers exist for molecules with C=C double bonds but not for molecules with C–C single bonds?', ARRAY['The pi bond in a C=C double bond prevents free rotation about the bond axis because rotating the pi bond would require breaking the sideways overlap of the p orbitals; the C–C single bond has only sigma bond overlap, allowing free rotation.','The C=C bond is shorter than the C–C bond, which locks the atoms in position.','The sp² hybridization of the C=C carbons makes the bonds rigid, whereas sp³ carbons in a C–C bond can rotate freely because they are tetrahedral.','C=C double bonds have greater bond energy than C–C single bonds, making rotation energetically impossible.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Molecular Polarity',
    'mc_static',
    'easy',
    ARRAY['molecular_polarity','dipole_moment','symmetry'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"O=C=O","caption":"Carbon dioxide (CO2)"}'::jsonb,
    '{"stem":"CO₂ has two polar C=O bonds, yet it is a nonpolar molecule. Which of the following best explains this?","options":["CO₂ is linear, so the two bond dipoles point in exactly opposite directions and cancel each other out, resulting in a net dipole moment of zero.","CO₂ is nonpolar because carbon and oxygen have similar electronegativities.","CO₂ is nonpolar because the two C=O double bonds share electrons equally.","CO₂ is nonpolar because it is a gas at room temperature."],"correct_index":0}'::jsonb,
    '119174c352fb0d6af65392f467f34e3254ef5d825b788a0ea36aa0a4f8845dee'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'CO₂ has two polar C=O bonds, yet it is a nonpolar molecule. Which of the following best explains this?', ARRAY['CO₂ is linear, so the two bond dipoles point in exactly opposite directions and cancel each other out, resulting in a net dipole moment of zero.','CO₂ is nonpolar because carbon and oxygen have similar electronegativities.','CO₂ is nonpolar because the two C=O double bonds share electrons equally.','CO₂ is nonpolar because it is a gas at room temperature.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Molecular Polarity',
    'mc_static',
    'medium',
    ARRAY['molecular_polarity','dipole_moment','symmetry','vsepr'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following molecules has a nonzero dipole moment (is polar)?","options":["H₂O, because its bent geometry means the two O–H bond dipoles do not cancel.","BF₃, because fluorine is more electronegative than boron.","CCl₄, because the four C–Cl bonds are all polar.","BCl₃, because boron has an incomplete octet."],"correct_index":0}'::jsonb,
    'd48fcfd6eb7f7ece0ff4a0559582f690a6c1912d4deadc1f026f358c0ceb7dab'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following molecules has a nonzero dipole moment (is polar)?', ARRAY['H₂O, because its bent geometry means the two O–H bond dipoles do not cancel.','BF₃, because fluorine is more electronegative than boron.','CCl₄, because the four C–Cl bonds are all polar.','BCl₃, because boron has an incomplete octet.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Molecular Polarity',
    'mc_static',
    'hard',
    ARRAY['molecular_polarity','dipole_moment','lone_pairs','geometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Both NF₃ and BF₃ have three fluorine atoms bonded to a central atom, but NF₃ is polar while BF₃ is nonpolar. Which of the following best explains this difference?","options":["NF₃ is trigonal pyramidal due to the lone pair on nitrogen, so the bond dipoles do not cancel; BF₃ is trigonal planar with no lone pair, so the bond dipoles cancel symmetrically.","NF₃ is polar because N–F bonds are more polar than B–F bonds.","BF₃ is nonpolar because boron is less electronegative than nitrogen.","NF₃ is polar because nitrogen has more valence electrons than boron."],"correct_index":0}'::jsonb,
    'ba8ac4a73c06d9f6ad6d743bc1db6e68dfdd7c6aec52db2c8aefc207fdc529ab'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Both NF₃ and BF₃ have three fluorine atoms bonded to a central atom, but NF₃ is polar while BF₃ is nonpolar. Which of the following best explains this difference?', ARRAY['NF₃ is trigonal pyramidal due to the lone pair on nitrogen, so the bond dipoles do not cancel; BF₃ is trigonal planar with no lone pair, so the bond dipoles cancel symmetrically.','NF₃ is polar because N–F bonds are more polar than B–F bonds.','BF₃ is nonpolar because boron is less electronegative than nitrogen.','NF₃ is polar because nitrogen has more valence electrons than boron.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_static',
    'easy',
    ARRAY['bond_energy','bond_order','sigma_pi_bonds'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following bonds has the highest bond energy?","options":["C≡C (triple bond), because it has three bonding interactions (1 sigma + 2 pi) giving it the highest bond order.","C–C (single bond), because sigma bonds are stronger than pi bonds.","C=C (double bond), because two bonds are always stronger than one.","C–H (single bond), because hydrogen is lighter and the bond vibrates at a higher frequency."],"correct_index":0}'::jsonb,
    'f1af86c22b55ab1038eb07a3055e776bdbf2ff426ea8d61e4e5b99def0636cbd'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following bonds has the highest bond energy?', ARRAY['C≡C (triple bond), because it has three bonding interactions (1 sigma + 2 pi) giving it the highest bond order.','C–C (single bond), because sigma bonds are stronger than pi bonds.','C=C (double bond), because two bonds are always stronger than one.','C–H (single bond), because hydrogen is lighter and the bond vibrates at a higher frequency.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_static',
    'medium',
    ARRAY['bond_length','atomic_radius','bond_order'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which factor MOST directly explains why a C–Cl bond is longer than a C–F bond?","options":["Chlorine has a larger atomic radius than fluorine because it has more electron shells, increasing the internuclear distance.","The C–Cl bond has a higher bond order than the C–F bond.","Chlorine is less electronegative than fluorine, which lengthens the bond by reducing the sharing of electrons.","Carbon forms a stronger bond with fluorine than with chlorine, which compresses the C–F bond."],"correct_index":0}'::jsonb,
    'e911b5886cfb15ca3f82f8d1b1bc7cb7f7e4ebd5d316e1f6f6a204b43c091f48'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which factor MOST directly explains why a C–Cl bond is longer than a C–F bond?', ARRAY['Chlorine has a larger atomic radius than fluorine because it has more electron shells, increasing the internuclear distance.','The C–Cl bond has a higher bond order than the C–F bond.','Chlorine is less electronegative than fluorine, which lengthens the bond by reducing the sharing of electrons.','Carbon forms a stronger bond with fluorine than with chlorine, which compresses the C–F bond.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_static',
    'hard',
    ARRAY['bond_energy','sigma_pi_bonds','bond_order'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a C=C double bond, the bond energy is 614 kJ/mol, while a C–C single bond has energy 347 kJ/mol. The pi bond energy is approximately 614 − 347 = 267 kJ/mol, which is less than the sigma bond energy of 347 kJ/mol. Which of the following best explains why pi bonds are weaker than sigma bonds?","options":["Pi bonds involve lateral (side-by-side) overlap of p orbitals, which produces less effective orbital overlap than the head-on overlap in sigma bonds.","Pi bonds are weaker because they involve more electrons than sigma bonds.","Pi bonds are weaker because they form between unhybridized orbitals that are farther from the nucleus.","Pi bonds are weaker because they can rotate freely, which reduces orbital overlap."],"correct_index":0}'::jsonb,
    'e89b2741eec3c5d6ee1e275cc4bf5b44b6573af9b42d0f34b7934701368ca7ba'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'In a C=C double bond, the bond energy is 614 kJ/mol, while a C–C single bond has energy 347 kJ/mol. The pi bond energy is approximately 614 − 347 = 267 kJ/mol, which is less than the sigma bond energy of 347 kJ/mol. Which of the following best explains why pi bonds are weaker than sigma bonds?', ARRAY['Pi bonds involve lateral (side-by-side) overlap of p orbitals, which produces less effective orbital overlap than the head-on overlap in sigma bonds.','Pi bonds are weaker because they involve more electrons than sigma bonds.','Pi bonds are weaker because they form between unhybridized orbitals that are farther from the nucleus.','Pi bonds are weaker because they can rotate freely, which reduces orbital overlap.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_numeric',
    'easy',
    ARRAY['electronegativity','bond_polarity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Two elements have electronegativities of {{a}} and {{b}} (Pauling scale). What is the electronegativity difference between them?","params":{"a":{"min":0.8,"max":2,"step":0.2},"b":{"min":3,"max":4,"step":0.2}},"answer_formula":"b - a","precision":1,"unit":"Pauling units","distractors":[{"formula":"b + a","error_type":"added_electronegativities_instead_of_finding_difference"},{"formula":"b - 3 * a","error_type":"subtracted_three_times_the_lower_electronegativity_instead_of_once"},{"formula":"b - 2 * a","error_type":"subtracted_twice_the_lower_electronegativity_instead_of_once"}]}'::jsonb,
    'b3bb5e544c47c2aecf6f7be9e8ae53430885d7fee051b160ad8194f555d9ac91'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_numeric',
    'easy',
    ARRAY['bond_energy','enthalpy','bond_breaking'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A reaction requires breaking {{a}} moles of O–H bonds. If the bond energy of an O–H bond is {{b}} kJ/mol, how much energy (in kJ) is required to break all these bonds?","params":{"a":{"min":2,"max":6,"step":1},"b":{"min":400,"max":500,"step":20}},"answer_formula":"a * b","precision":0,"unit":"kJ","distractors":[{"formula":"a + b","error_type":"added_moles_and_bond_energy_instead_of_multiplying"},{"formula":"b / a","error_type":"divided_bond_energy_by_moles_instead_of_multiplying"},{"formula":"a * b * 2","error_type":"incorrectly_doubled_the_result"}]}'::jsonb,
    'beb301b92234d570611c82f5a7f81d34bf0a3f768e226389f06b218ea864e145'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_numeric',
    'easy',
    ARRAY['bond_energy','enthalpy','bond_forming'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A reaction forms {{a}} moles of N–H bonds. If the bond energy of an N–H bond is {{b}} kJ/mol, how much energy (in kJ) is released when all these bonds form? (Bond formation releases energy.)","params":{"a":{"min":1,"max":4,"step":1},"b":{"min":380,"max":420,"step":10}},"answer_formula":"a * b","precision":0,"unit":"kJ","distractors":[{"formula":"a + b","error_type":"added_instead_of_multiplied"},{"formula":"b - a","error_type":"subtracted_moles_from_bond_energy_instead_of_multiplying"},{"formula":"a * b / 2","error_type":"halved_result_incorrectly"}]}'::jsonb,
    'ae20994ad3e459233cf8d2ae2200fbdc384dc6c11b7b84c2e430835a20a7efab'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_numeric',
    'medium',
    ARRAY['bond_energy','enthalpy_of_reaction','hess_law_bond_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Using bond energies, estimate ΔH for a reaction that breaks {{a}} kJ of bonds and forms {{b}} kJ of bonds. (ΔH = energy to break bonds − energy released forming bonds)","params":{"a":{"min":300,"max":800,"step":50},"b":{"min":400,"max":900,"step":50}},"answer_formula":"a - b","precision":0,"unit":"kJ/mol","distractors":[{"formula":"a - 2 * b","error_type":"subtracted_double_the_bond_formation_energy_instead_of_single"},{"formula":"a + b","error_type":"added_bond_breaking_and_forming_energies_instead_of_subtracting"},{"formula":"(a + b) / 2","error_type":"averaged_the_two_energies_instead_of_subtracting"}],"allow_negative":true}'::jsonb,
    '33ab23f15ec5f7031190646da8360d42db186ed8335dd797b5cf5cba4349bd25'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_numeric',
    'easy',
    ARRAY['lewis_structure','valence_electrons','electron_count'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A neutral molecule has a central atom from Group {{a}} and is bonded to {{b}} hydrogen atoms (each contributing 1 valence electron). Assuming the central atom contributes its group number of valence electrons, how many total valence electrons does this molecule have?","params":{"a":{"min":4,"max":7,"step":1},"b":{"min":1,"max":4,"step":1}},"answer_formula":"a + b","precision":0,"unit":"electrons","distractors":[{"formula":"a * b","error_type":"multiplied_group_number_by_hydrogen_count_instead_of_adding"},{"formula":"a - b","error_type":"subtracted_hydrogen_count_from_group_number"},{"formula":"2 * a + b","error_type":"double_counted_the_central_atom_valence_electrons"}]}'::jsonb,
    '5259a71788fbce7f5e4d824d4228b2ec0c50b112f6d72691666ce329ce6d0140'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_numeric',
    'medium',
    ARRAY['formal_charge','lewis_structure','calculation'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Formal charge is calculated as: FC = (valence electrons of free atom) − (lone pair electrons on atom) − ½(bonding electrons on atom). An atom has {{a}} valence electrons in its free state, {{b}} lone-pair electrons in the Lewis structure, and 4 bonding electrons. What is the formal charge?","params":{"a":{"min":4,"max":7,"step":1},"b":{"min":2,"max":6,"step":2}},"answer_formula":"a - b - 2","precision":0,"unit":"","distractors":[{"formula":"a - b - 4","error_type":"subtracted_all_bonding_electrons_instead_of_half"},{"formula":"a + b - 2","error_type":"added_lone_pair_electrons_instead_of_subtracting"},{"formula":"a - b","error_type":"forgot_to_subtract_the_half_bonding_electron_contribution"}],"allow_negative":true}'::jsonb,
    '96c18a18c3e5ad777bdcfb72357068f20ecd729bd0adb76ba94912b26e092ec7'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_numeric',
    'medium',
    ARRAY['lattice_energy','coulombs_law','ionic_charge'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Lattice energy is proportional to (q₊ × q₋) / r, where q₊ and q₋ are the ionic charges and r is the interionic distance. Compound A has ionic charges of +{{a}} and −1, while Compound B has ionic charges of +1 and −1, with the same interionic distance. By what factor is Compound A''s lattice energy greater than Compound B''s?","params":{"a":{"min":2,"max":4,"step":1}},"answer_formula":"a","precision":0,"unit":"× greater","distractors":[{"formula":"a * a","error_type":"squared_the_charge_factor_incorrectly"},{"formula":"a + 1","error_type":"added_1_to_charge_instead_of_using_ratio_directly"},{"formula":"a / 2","error_type":"halved_the_charge_factor_incorrectly"}]}'::jsonb,
    '0515d4f55f89e14e62fb0e4e2bbfee92978eefbc56e087f9280ab2408446964d'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_numeric',
    'medium',
    ARRAY['lattice_energy','ionic_radius','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Lattice energy is proportional to 1/r (interionic distance). If Compound X has an interionic distance of {{a}} pm and Compound Y has an interionic distance of {{b}} pm ({{b}} > {{a}}), what is the ratio of lattice energy of X to lattice energy of Y? (Express as a decimal.)","params":{"a":{"min":200,"max":300,"step":20},"b":{"min":320,"max":400,"step":20}},"answer_formula":"b / a","precision":2,"unit":"(ratio X:Y)","distractors":[{"formula":"a / b","error_type":"calculated_ratio_of_Y_to_X_instead_of_X_to_Y"},{"formula":"b - a","error_type":"subtracted_distances_instead_of_taking_ratio"},{"formula":"(a + b) / 2","error_type":"averaged_interionic_distances_instead_of_finding_ratio"}]}'::jsonb,
    'bf04f2ae54fb7acb15bb62d5d8fd23e41060b92ea1478d766d538d90a858559e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_numeric',
    'easy',
    ARRAY['vsepr','electron_groups','lone_pairs'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A central atom has {{a}} total electron groups, of which {{b}} are lone pairs. How many bonding pairs surround the central atom?","params":{"a":{"min":3,"max":6,"step":1},"b":{"min":1,"max":2,"step":1}},"answer_formula":"a - b","precision":0,"unit":"bonding pairs","distractors":[{"formula":"a + b","error_type":"added_lone_pairs_instead_of_subtracting"},{"formula":"a * b","error_type":"multiplied_total_groups_by_lone_pairs"},{"formula":"b - a","error_type":"subtracted_total_from_lone_pairs_reversing_the_direction"}]}'::jsonb,
    '9a20774bb168340904525f5edb9933f61f00dc01438772a22a03dd0b53359580'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_numeric',
    'medium',
    ARRAY['bond_energy','enthalpy','stoichiometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A diatomic molecule A₂ has a bond energy of {{a}} kJ/mol. How much energy (in kJ) is required to completely dissociate {{b}} moles of A₂ into individual atoms?","params":{"a":{"min":150,"max":500,"step":50},"b":{"min":2,"max":8,"step":2}},"answer_formula":"a * b","precision":0,"unit":"kJ","distractors":[{"formula":"a + b","error_type":"added_bond_energy_and_moles_instead_of_multiplying"},{"formula":"a / b","error_type":"divided_bond_energy_by_moles_instead_of_multiplying"},{"formula":"a * b * 2","error_type":"doubled_the_result_incorrectly_treating_each_molecule_as_having_two_bonds"}]}'::jsonb,
    'df37292e9e7cb27fff49f712b5757850b2f861289777f5d34474fea0948e5863'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'mc_numeric',
    'medium',
    ARRAY['formal_charge','valence_electrons','polyatomic_ion'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"An anion has a charge of −{{a}}. It is formed from a neutral molecule that has {{b}} total valence electrons. How many valence electrons does the anion have?","params":{"a":{"min":1,"max":3,"step":1},"b":{"min":16,"max":32,"step":2}},"answer_formula":"b + a","precision":0,"unit":"electrons","distractors":[{"formula":"b - a","error_type":"subtracted_charge_instead_of_adding_electrons_for_negative_charge"},{"formula":"b * a","error_type":"multiplied_valence_electrons_by_charge_instead_of_adding"},{"formula":"b + a + 2","error_type":"added_extra_2_electrons_incorrectly"}]}'::jsonb,
    '6356b92863cce7950253190a32eae952ad369e410eec738a5d54478819278f51'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_numeric',
    'medium',
    ARRAY['bond_energy','bond_order','potential_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A single bond X–X has a bond energy of {{a}} kJ/mol. If a double bond X=X has approximately {{b}} times the bond energy of a single X–X bond, what is the estimated bond energy of X=X?","params":{"a":{"min":200,"max":400,"step":50},"b":{"min":1.5,"max":2,"step":0.5}},"answer_formula":"a * b","precision":0,"unit":"kJ/mol","distractors":[{"formula":"a + b","error_type":"added_factor_to_single_bond_energy_instead_of_multiplying"},{"formula":"a / b","error_type":"divided_single_bond_energy_by_factor_instead_of_multiplying"},{"formula":"a * b + 50","error_type":"added_extra_50_kJ_to_the_product_without_justification"}]}'::jsonb,
    '307c0ddf661d98d10643a4cdd2084341faf7be2c4e9e536f004b2a8fc18dd9a9'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_numeric',
    'medium',
    ARRAY['lewis_structure','valence_electrons','cation'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A cation has a charge of +{{a}}. It is formed from a neutral atom that has {{b}} valence electrons. How many valence electrons remain in the cation?","params":{"a":{"min":1,"max":3,"step":1},"b":{"min":4,"max":8,"step":1}},"answer_formula":"b - a","precision":0,"unit":"electrons","distractors":[{"formula":"b + a","error_type":"added_charge_instead_of_subtracting_electrons_for_positive_charge"},{"formula":"a * b","error_type":"multiplied_valence_electrons_by_charge"},{"formula":"b - a + 3","error_type":"miscounted_by_adding_3_extra_electrons_to_the_valence_count"}]}'::jsonb,
    '4ac65fc8a06568356e16551e04121ed33648e432808682a36c6b5806e341ee83'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_numeric',
    'hard',
    ARRAY['lattice_energy','born_haber','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Lattice energy scales proportionally with (q₊ × |q₋|). Compound A has singly charged ions (q₊ = 1, q₋ = −1). Compound B has charges of q₊ = +{{a}} and q₋ = −{{b}}, with the same interionic distance. By what factor is Compound B''s lattice energy greater than Compound A''s?","params":{"a":{"min":2,"max":3,"step":1},"b":{"min":2,"max":3,"step":1}},"answer_formula":"a * b","precision":0,"unit":"× greater","distractors":[{"formula":"(a + b) * 2","error_type":"doubled_the_sum_of_charges_instead_of_multiplying_them"},{"formula":"a * b + 1","error_type":"added_1_to_the_product_incorrectly"},{"formula":"(a + b) / 2","error_type":"averaged_the_charges_instead_of_finding_their_product"}]}'::jsonb,
    'e118ce41419cb84afe35d35b880f0b3af9c78a6ab4cf8f44b56b04f9c5f4e47a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'mc_numeric',
    'hard',
    ARRAY['bond_energy','resonance','bond_order'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A molecule with resonance has {{a}} equivalent bonds. If the total bond energy for all these equivalent bonds together is {{b}} kJ/mol, what is the average bond energy per bond?","params":{"a":{"min":2,"max":4,"step":1},"b":{"min":600,"max":1200,"step":100}},"answer_formula":"b / a","precision":0,"unit":"kJ/mol","distractors":[{"formula":"b * a","error_type":"multiplied_total_energy_by_number_of_bonds_instead_of_dividing"},{"formula":"b - a","error_type":"subtracted_number_of_bonds_from_total_energy"},{"formula":"b + a","error_type":"added_number_of_bonds_to_total_energy"}]}'::jsonb,
    '12bc6830e9e35419465d8e3107cf3d4ca45102fa7093c9db1318acb3e3b0bf54'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'mc_numeric',
    'hard',
    ARRAY['bond_angle','lone_pairs','vsepr'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"The ideal tetrahedral bond angle is 109.5°. Each lone pair on a central atom reduces the observed bond angle by approximately {{a}}° relative to the last lone pair''s effect. If a molecule has 2 lone pairs on its central atom (like H₂O), and the baseline tetrahedral angle is 109.5°, what is the approximate observed bond angle? (Subtract {{a}}° twice from 109.5°.)","params":{"a":{"min":1,"max":3,"step":1}},"answer_formula":"109.5 - 2 * a","precision":1,"unit":"degrees","distractors":[{"formula":"109.5 - a","error_type":"subtracted_lone_pair_effect_only_once_instead_of_twice"},{"formula":"109.5 + 2 * a","error_type":"added_lone_pair_effect_instead_of_subtracting"},{"formula":"120 - 2 * a","error_type":"used_trigonal_planar_baseline_instead_of_tetrahedral"}]}'::jsonb,
    '25d3a0837d67404cf5ba5a77f3cc8cf387f162b89322d2f30dfe8ff39732286f'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Intramolecular Force and Potential Energy',
    'mc_numeric',
    'hard',
    ARRAY['bond_energy','enthalpy','net_reaction'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Using bond energies, ΔH ≈ (sum of energies of bonds broken) − (sum of energies of bonds formed). A reaction breaks {{a}} C–H bonds (413 kJ/mol each) and {{b}} Cl–Cl bonds (242 kJ/mol each), then forms {{a}} C–Cl bonds (339 kJ/mol each) and {{b}} H–Cl bonds (427 kJ/mol each). What is the estimated ΔH?","params":{"a":{"min":1,"max":3,"step":1},"b":{"min":1,"max":3,"step":1}},"answer_formula":"a * 413 + b * 242 - a * 339 - b * 427","precision":0,"unit":"kJ/mol","distractors":[{"formula":"a * 413 + b * 242 + a * 339 + b * 427","error_type":"added_all_bond_energies_instead_of_subtracting_bonds_formed"},{"formula":"a * 339 + b * 427 - a * 413 - b * 242","error_type":"subtracted_bonds_broken_from_bonds_formed_reversing_sign"},{"formula":"a * 413 - b * 242 - a * 339 + b * 427","error_type":"mixed_up_signs_for_Cl_Cl_and_HCl_bond_contributions"}],"allow_negative":true}'::jsonb,
    'ff2677bb0d5012931f338efe7b204757bc772745ca44f121ab8c45e7af087501'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'mc_numeric',
    'medium',
    ARRAY['bond_polarity','electronegativity_difference'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Element A has electronegativity {{a}} and Element B has electronegativity {{b}} (where {{b}} > {{a}}). If the bond dipole magnitude is proportional to the electronegativity difference, and a reference bond with Δ EN = 1.0 has a dipole of 1.00 D, what is the relative dipole of the A–B bond? (Assume linear proportionality.)","params":{"a":{"min":1,"max":2.5,"step":0.5},"b":{"min":3,"max":4,"step":0.5}},"answer_formula":"b - a","precision":1,"unit":"D (relative)","distractors":[{"formula":"b + a","error_type":"added_electronegativities_instead_of_finding_their_difference"},{"formula":"b - 3 * a","error_type":"subtracted_triple_the_lower_electronegativity_instead_of_single_difference"},{"formula":"(b - a) / 2","error_type":"halved_the_electronegativity_difference_incorrectly"}]}'::jsonb,
    '77dd8f3648f542f868063d2d544da9f4e2e66d32a2fc86effff43dc2a45e227e'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'mc_numeric',
    'hard',
    ARRAY['lewis_structure','lone_pairs','valence_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A molecule has {{a}} total valence electrons and {{b}} bonding pairs. How many lone-pair electrons remain?","params":{"a":{"min":8,"max":24,"step":2},"b":{"min":1,"max":4,"step":1}},"answer_formula":"a - 2 * b","precision":0,"unit":"electrons","distractors":[{"formula":"a - b","error_type":"subtracted_bonding_pairs_instead_of_bonding_electrons_did_not_multiply_by_2"},{"formula":"a + 2 * b","error_type":"added_bonding_electrons_instead_of_subtracting"},{"formula":"a * b","error_type":"multiplied_total_valence_electrons_by_bonding_pairs"}]}'::jsonb,
    'ea8937d77d703972d529f48be0e6825a4c9e2db60c798eb150d33c2c22cdaf6f'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'mc_numeric',
    'hard',
    ARRAY['lattice_energy','melting_point','coulombs_law','ionic_radius'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"For an ionic compound, lattice energy ∝ (q₊ × |q₋|) / r. Compound P has q₊ = {{a}}, q₋ = −1, and interionic distance r = {{b}} pm. Compound Q has q₊ = 1, q₋ = −1, and interionic distance r = {{b}} pm. What is the ratio of lattice energy of P to lattice energy of Q?","params":{"a":{"min":2,"max":4,"step":1},"b":{"min":200,"max":300,"step":20}},"answer_formula":"a","precision":0,"unit":"(ratio P:Q)","distractors":[{"formula":"a + 1","error_type":"added_1_to_charge_ratio_instead_of_recognizing_direct_proportionality"},{"formula":"a * b","error_type":"multiplied_charge_by_distance_instead_of_just_using_charge_ratio"},{"formula":"a / b","error_type":"divided_charge_by_distance_rather_than_using_charge_ratio_alone"}]}'::jsonb,
    'e02500b9491c3201dfb7b301dc37a9c555c7a467212545b4389d436831272d94'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'fr_static',
    'easy',
    ARRAY['ionic_bond','definition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What type of chemical bond results from the complete transfer of one or more valence electrons from a metal to a nonmetal, creating oppositely charged ions held together by electrostatic attraction?","accepted_answers":["ionic bond","ionic bonding","electrostatic attraction"],"semantic_fallback":true}'::jsonb,
    '194afe144df58e84fbefa0481c92e852735918124ef714c01abf77143e6ee38c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Chemical Bonds',
    'fr_static',
    'easy',
    ARRAY['metallic_bonding','sea_of_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In the metallic bonding model, the valence electrons of metal atoms are not localized between any two atoms but instead move freely throughout the lattice. What common phrase is used to describe these delocalized valence electrons in a metal?","accepted_answers":["sea of electrons","electron sea","delocalized electrons","sea of delocalized electrons"],"semantic_fallback":true}'::jsonb,
    '66a23563d3b97081ab61ffbffcaab080d9e1e95df0cc6115619ea020a800ca59'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Metals and Alloys',
    'fr_static',
    'easy',
    ARRAY['alloys','interstitial_alloy','substitutional_alloy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What type of alloy forms when atoms of significantly different radii combine, with the smaller atoms occupying the gaps (spaces) between the larger atoms in the metal lattice?","accepted_answers":["interstitial alloy","interstitial"],"semantic_fallback":true}'::jsonb,
    '7c662d5975202595f3e94494e25cc5ad374e29cc1d34230f997559f93058eaae'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Lewis Diagrams',
    'fr_static',
    'easy',
    ARRAY['octet_rule','lewis_structure'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What rule states that atoms in Lewis structures tend to have 8 electrons (4 pairs) in their valence shell, giving them the electron configuration of a noble gas?","accepted_answers":["octet rule","the octet rule"],"semantic_fallback":true}'::jsonb,
    'f34bf31f43233d6bcc68846076f148714cadeb030c8c7ea46d85a1a9c225cf91'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'fr_static',
    'medium',
    ARRAY['resonance','delocalization','definition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"When more than one valid Lewis structure can be drawn for a molecule or ion by changing only the positions of electrons (not atoms), these structures are called what? The actual molecule is a hybrid of all of them.","accepted_answers":["resonance structures","resonance","resonance forms","resonance hybrids"],"semantic_fallback":true}'::jsonb,
    '5ff964bfbc64957630b96bd9a39a2a52b43f38c4d598015c6615ce901ef722b1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'fr_static',
    'medium',
    ARRAY['vsepr','electron_pair_repulsion','molecular_geometry'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What theory uses the repulsion between electron pairs (both bonding pairs and lone pairs) around a central atom to predict the three-dimensional shape of a molecule?","accepted_answers":["vsepr theory","vsepr","valence shell electron pair repulsion theory","valence shell electron pair repulsion"],"semantic_fallback":true}'::jsonb,
    '6ff6b1b98b272c980be521a9796cfe055e5256e0c2ab0ae4e75806d49e38af81'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'VSEPR and Molecular Geometry',
    'fr_static',
    'medium',
    ARRAY['molecular_geometry','trigonal_pyramidal','vsepr'],
    'ced_generated',
    true,
    '{"type":"smiles","value":"N","caption":"Ammonia (NH3)"}'::jsonb,
    '{"stem":"What is the molecular geometry (shape) of ammonia (NH₃), which has a central nitrogen atom with 3 bonding pairs and 1 lone pair?","accepted_answers":["trigonal pyramidal","trigonal-pyramidal","pyramidal"],"semantic_fallback":true}'::jsonb,
    '9dbb8c8807edc8981dfb38c3acec5ab9f2bd9ab792d46701e656e2ec17ba8e81'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'fr_static',
    'medium',
    ARRAY['hybridization','sigma_bond','pi_bond','definition'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In orbital overlap theory, what type of bond results from the direct (head-on) overlap of atomic orbitals along the bond axis, and is found in all covalent bonds (single, double, and triple)?","accepted_answers":["sigma bond","sigma","σ bond"],"semantic_fallback":true}'::jsonb,
    'dcfae2b7656cd38c97f972fa9803af58ddd94bc129fcb4f22cf7f8f420155b46'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Hybridization',
    'fr_static',
    'medium',
    ARRAY['hybridization','pi_bond','double_bond','triple_bond'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"What type of bond results from the lateral (side-by-side) overlap of parallel p orbitals, is present in double and triple bonds (but not single bonds), and prevents free rotation around the bond?","accepted_answers":["pi bond","pi","π bond"],"semantic_fallback":true}'::jsonb,
    '1015d08621cd618e85131280743a4ce6598048f417a8b96e734ab010e4aa7bd1'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Molecular Polarity',
    'fr_static',
    'hard',
    ARRAY['molecular_polarity','dipole_moment','bond_dipoles'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A molecule can have polar bonds and yet be nonpolar overall. What geometric condition must be satisfied for the individual bond dipoles to cancel each other and produce a zero net dipole moment?","accepted_answers":["the molecule must be symmetrical so that bond dipoles cancel","the bond dipoles must be equal and opposite and cancel due to molecular symmetry","the molecule must have a symmetrical geometry with no lone pairs on the central atom","symmetric arrangement of bond dipoles"],"semantic_fallback":true}'::jsonb,
    'dcc4735aaf1154d4ed11ff3583375a3f48c4c856f057d8d2c56e1839fd49aa0c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'fr_static',
    'hard',
    ARRAY['formal_charge','best_lewis_structure','octet_rule'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"When choosing among several possible Lewis structures for the same molecule, which two criteria based on formal charge are used to identify the best (most accurate) Lewis structure?","accepted_answers":["formal charges should be as close to zero as possible and negative formal charge should be on the more electronegative atom","minimize formal charges and place negative formal charge on the most electronegative atom","smallest formal charges and negative charge on electronegative atom"],"semantic_fallback":true}'::jsonb,
    '3d4aa02413b747cfcd7e5d5d44e12e89ef506c8429a3331c1b47956da26246ca'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'fr_static',
    'hard',
    ARRAY['bond_length','bond_energy','bond_order','relationship'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Describe the relationship between bond order, bond length, and bond energy. Your answer should address the direction of all three relationships.","accepted_answers":["as bond order increases bond length decreases and bond energy increases","higher bond order means shorter bond length and greater bond energy","bond order and bond energy are directly proportional while bond order and bond length are inversely proportional"],"semantic_fallback":true}'::jsonb,
    '7d5cfadc9530cae4bb981ed788c72dd912966b9ef5da2ae0a620fa45c0e703d4'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'fr_numeric',
    'medium',
    ARRAY['bond_energy','enthalpy','calculation'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Using bond energies, estimate ΔH (in kJ/mol) for a reaction in which {{a}} C–H bonds (413 kJ/mol each) and {{b}} O=O bonds (498 kJ/mol each) are broken, and {{a}} C=O bonds (799 kJ/mol each) and {{b}} O–H bonds (463 kJ/mol each) are formed. (ΔH = bonds broken − bonds formed)","params":{"a":{"min":1,"max":4,"step":1},"b":{"min":1,"max":2,"step":1}},"answer_formula":"a * 413 + b * 498 - a * 799 - b * 463","precision":0,"unit":"kJ/mol","tolerance":0,"semantic_fallback":false,"allow_negative":true}'::jsonb,
    'e7fd29909ba65682f63fa72b41e0177397134db2726d53d416e8a040abc2ef4c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Resonance and Formal Charge',
    'fr_numeric',
    'medium',
    ARRAY['formal_charge','lewis_structure','calculation'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Calculate the formal charge on an atom that has {{a}} valence electrons in its free state, {{b}} lone-pair electrons in its Lewis structure, and 6 bonding electrons shared with neighboring atoms. (FC = valence electrons − lone pair electrons − ½ × bonding electrons)","params":{"a":{"min":4,"max":7,"step":1},"b":{"min":0,"max":6,"step":2}},"answer_formula":"a - b - 3","precision":0,"unit":"","tolerance":0,"semantic_fallback":false,"allow_negative":true}'::jsonb,
    '7aa640e19f3938f506adef5138a9c5e7c87ed4bf986989cbcb079a1b50bb6789'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Structure of Ionic Solids',
    'fr_numeric',
    'hard',
    ARRAY['lattice_energy','coulombs_law','charge_distance'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A simplified lattice energy model gives U ∝ (q₊ × |q₋|) / r. Compound A has q₊ = {{a}}, |q₋| = {{b}}, and interionic distance r = 200 pm. What is the relative lattice energy of Compound A compared to a reference compound with q₊ = 1, |q₋| = 1, and r = 200 pm? Express as a ratio (A / reference).","params":{"a":{"min":1,"max":3,"step":1},"b":{"min":1,"max":3,"step":1}},"answer_formula":"a * b","precision":0,"unit":"(dimensionless ratio)","tolerance":0,"semantic_fallback":false}'::jsonb,
    '14d40689e6c19b4c311231e9b775bcf070a5ae2ea8962e27547aa0b736fea104'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Bond Length and Bond Energy',
    'fr_numeric',
    'hard',
    ARRAY['bond_energy','enthalpy','combustion'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Estimate ΔH (in kJ/mol) for a reaction using bond energies. The reaction breaks {{a}} N–H bonds (391 kJ/mol each) and {{b}} O=O bonds (498 kJ/mol each), and forms {{b}} N=O bonds (631 kJ/mol each) and {{a}} O–H bonds (463 kJ/mol each).","params":{"a":{"min":2,"max":6,"step":2},"b":{"min":1,"max":3,"step":1}},"answer_formula":"a * 391 + b * 498 - b * 631 - a * 463","precision":0,"unit":"kJ/mol","tolerance":0,"semantic_fallback":false,"allow_negative":true}'::jsonb,
    'b36ca069b46cd06183c449970d157625fdad71565e94cd907490c20a0cfbefe2'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_static',
    'easy',
    ARRAY['covalent_network_solid','types_of_solids','properties'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following best describes a covalent network solid?","options":["A solid in which all atoms are held together by a continuous, three-dimensional network of covalent bonds extending throughout the entire crystal.","A solid composed of discrete molecules held together by intermolecular forces such as London dispersion forces.","A solid composed of alternating cations and anions arranged in a regular lattice held by electrostatic attraction.","A solid in which positive ion cores are surrounded by a sea of delocalized electrons."],"correct_index":0}'::jsonb,
    'b1330ee7080f6f08d8f85d51723747b5ae6ce73ef1af4269e7e31f848009a09a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following best describes a covalent network solid?', ARRAY['A solid in which all atoms are held together by a continuous, three-dimensional network of covalent bonds extending throughout the entire crystal.','A solid composed of discrete molecules held together by intermolecular forces such as London dispersion forces.','A solid composed of alternating cations and anions arranged in a regular lattice held by electrostatic attraction.','A solid in which positive ion cores are surrounded by a sea of delocalized electrons.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_static',
    'easy',
    ARRAY['types_of_solids','classification','properties'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Which of the following correctly matches each solid type with the primary force holding its particles together?","options":["Ionic solid — electrostatic attraction; metallic solid — delocalized electrons; molecular solid — intermolecular forces; covalent network solid — covalent bonds throughout.","Ionic solid — covalent bonds; metallic solid — ionic bonds; molecular solid — metallic bonds; covalent network solid — electrostatic attraction.","Ionic solid — delocalized electrons; metallic solid — covalent bonds; molecular solid — electrostatic attraction; covalent network solid — intermolecular forces.","Ionic solid — intermolecular forces; metallic solid — electrostatic attraction; molecular solid — covalent bonds; covalent network solid — delocalized electrons."],"correct_index":0}'::jsonb,
    'bdefb7611fa3a94b3e9602a361ecc5a32b30081f47425cbceef9bb15f6ed4115'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Which of the following correctly matches each solid type with the primary force holding its particles together?', ARRAY['Ionic solid — electrostatic attraction; metallic solid — delocalized electrons; molecular solid — intermolecular forces; covalent network solid — covalent bonds throughout.','Ionic solid — covalent bonds; metallic solid — ionic bonds; molecular solid — metallic bonds; covalent network solid — electrostatic attraction.','Ionic solid — delocalized electrons; metallic solid — covalent bonds; molecular solid — electrostatic attraction; covalent network solid — intermolecular forces.','Ionic solid — intermolecular forces; metallic solid — electrostatic attraction; molecular solid — covalent bonds; covalent network solid — delocalized electrons.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_static',
    'medium',
    ARRAY['covalent_network_solid','diamond','properties','high_melting_point'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Diamond has an extremely high melting point (about 3550 °C) and is one of the hardest known substances. Which of the following best explains these properties?","options":["Diamond is a covalent network solid in which every carbon atom is bonded to four other carbon atoms by strong covalent bonds extending throughout the entire crystal, so enormous energy is required to break the lattice.","Diamond is an ionic solid in which the carbon ions are held by very strong electrostatic forces that resist deformation.","Diamond is a molecular solid with exceptionally strong London dispersion forces because carbon atoms are very polarizable.","Diamond is a metallic solid whose delocalized electrons create unusually strong metallic bonds between carbon atoms."],"correct_index":0}'::jsonb,
    '901096a2bf09ffd16d71de09785a5e79549a400bf9e334cabfb3af404fe81251'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Diamond has an extremely high melting point (about 3550 °C) and is one of the hardest known substances. Which of the following best explains these properties?', ARRAY['Diamond is a covalent network solid in which every carbon atom is bonded to four other carbon atoms by strong covalent bonds extending throughout the entire crystal, so enormous energy is required to break the lattice.','Diamond is an ionic solid in which the carbon ions are held by very strong electrostatic forces that resist deformation.','Diamond is a molecular solid with exceptionally strong London dispersion forces because carbon atoms are very polarizable.','Diamond is a metallic solid whose delocalized electrons create unusually strong metallic bonds between carbon atoms.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_static',
    'medium',
    ARRAY['metallic_solid','properties','malleability','conductivity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Unlike ionic solids, metallic solids are malleable (can be hammered into sheets) rather than brittle. Which of the following best explains this difference using the sea-of-electrons model?","options":["When layers of metal atoms shift under stress, the delocalized electron sea adjusts continuously to maintain bonding throughout, so the solid bends rather than fractures; in ionic solids, shifting layers bring like charges adjacent, causing repulsion and fracture.","Metal atoms form weaker bonds than ions, so they can slide past each other without breaking the lattice.","The delocalized electrons in metals flow away from the stress point, reducing local bonding and allowing layers to slip.","Metals are malleable because they contain no anions that could repel each other when layers shift."],"correct_index":0}'::jsonb,
    'c7614ff50bd517aa8122b2477fb499db54902f2c2bb1c3ea6e2ef0c1af99110a'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'Unlike ionic solids, metallic solids are malleable (can be hammered into sheets) rather than brittle. Which of the following best explains this difference using the sea-of-electrons model?', ARRAY['When layers of metal atoms shift under stress, the delocalized electron sea adjusts continuously to maintain bonding throughout, so the solid bends rather than fractures; in ionic solids, shifting layers bring like charges adjacent, causing repulsion and fracture.','Metal atoms form weaker bonds than ions, so they can slide past each other without breaking the lattice.','The delocalized electrons in metals flow away from the stress point, reducing local bonding and allowing layers to slip.','Metals are malleable because they contain no anions that could repel each other when layers shift.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_static',
    'hard',
    ARRAY['types_of_solids','comparison','melting_point','conductivity'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A student compares four solids: (I) NaCl, (II) Cu, (III) SiO₂, (IV) CO₂(s). Which ranking of melting points from lowest to highest is correct, and which solid type explains the lowest melting point?","options":["CO₂(s) < NaCl < Cu < SiO₂; CO₂ is a molecular solid held only by weak London dispersion forces, giving it the lowest melting point.","NaCl < CO₂(s) < Cu < SiO₂; ionic solids always have lower melting points than molecular solids.","Cu < CO₂(s) < NaCl < SiO₂; metals have the lowest melting points because delocalized electrons are weakly bonded.","SiO₂ < NaCl < Cu < CO₂(s); covalent network solids always have the lowest melting points."],"correct_index":0}'::jsonb,
    '4f9ce8ac5bc532f67d9b75de213fe4adedc43200ffd32ea6832666480285460c'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  IF v_card_id IS NOT NULL THEN
    INSERT INTO public.question_variants (source_card_id, rendered_stem, rendered_options, correct_index, param_values)
    VALUES (v_card_id, 'A student compares four solids: (I) NaCl, (II) Cu, (III) SiO₂, (IV) CO₂(s). Which ranking of melting points from lowest to highest is correct, and which solid type explains the lowest melting point?', ARRAY['CO₂(s) < NaCl < Cu < SiO₂; CO₂ is a molecular solid held only by weak London dispersion forces, giving it the lowest melting point.','NaCl < CO₂(s) < Cu < SiO₂; ionic solids always have lower melting points than molecular solids.','Cu < CO₂(s) < NaCl < SiO₂; metals have the lowest melting points because delocalized electrons are weakly bonded.','SiO₂ < NaCl < Cu < CO₂(s); covalent network solids always have the lowest melting points.'], 0, NULL)
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_numeric',
    'medium',
    ARRAY['types_of_solids','melting_point_comparison','coulombs_law'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Solid A (molecular) melts at {{a}} °C and Solid B (covalent network) melts at {{b}} °C. By how many degrees Celsius does B''s melting point exceed A''s?","params":{"a":{"min":-100,"max":50,"step":25},"b":{"min":1000,"max":3000,"step":500}},"answer_formula":"b - a","precision":0,"unit":"°C","distractors":[{"formula":"a - b","error_type":"subtracted_in_wrong_order_giving_negative_value"},{"formula":"(b - a) * 2","error_type":"doubled_the_melting_point_difference_instead_of_reporting_it_directly"},{"formula":"(b - a) / 2","error_type":"halved_the_difference_incorrectly"}]}'::jsonb,
    '296ed6967b36c18ac8a983e1256ca9a5485fd420a7781b0c3524a08f38380701'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_numeric',
    'medium',
    ARRAY['metallic_solid','conductivity','free_electrons'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A metal sample contains {{a}} moles of atoms, each contributing {{b}} delocalized (free) valence electrons to the electron sea. How many total moles of free electrons are in the sample?","params":{"a":{"min":2,"max":8,"step":2},"b":{"min":1,"max":3,"step":1}},"answer_formula":"a * b","precision":0,"unit":"mol electrons","distractors":[{"formula":"a * b + b","error_type":"added_one_extra_electron_per_atom_after_multiplying"},{"formula":"a * b * 2","error_type":"doubled_the_total_electron_count_incorrectly"},{"formula":"a * b - b","error_type":"subtracted_one_electron_per_atom_from_product_instead_of_using_direct_multiply"}]}'::jsonb,
    '7b7695e7ca1386075e7d26f5e413e412296a82cc23263db37f14e00fbdca7307'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'mc_numeric',
    'hard',
    ARRAY['types_of_solids','lattice_energy','covalent_network','bond_energy'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"In a covalent network solid, each interior atom forms {{a}} covalent bonds, and each bond has an energy of {{b}} kJ/mol. Using the approximation that the energy per atom ≈ (number of bonds × bond energy) / 2 (dividing by 2 to avoid double-counting), what is the estimated energy per atom in kJ/mol?","params":{"a":{"min":2,"max":4,"step":1},"b":{"min":300,"max":500,"step":50}},"answer_formula":"a * b / 2","precision":0,"unit":"kJ/mol per atom","distractors":[{"formula":"a * b","error_type":"forgot_to_divide_by_2_to_avoid_double_counting_shared_bonds"},{"formula":"a + b","error_type":"added_bond_count_and_bond_energy_instead_of_multiplying"},{"formula":"b / a","error_type":"divided_bond_energy_by_bond_count_instead_of_multiplying_then_halving"}]}'::jsonb,
    '207191148e18d3c9cbc33b8e2b6b49e135e17bf5fb319c469d954e4aaf5d06cc'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'fr_static',
    'medium',
    ARRAY['covalent_network_solid','examples','properties'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"Name one example of a covalent network solid (other than diamond) that is known for its extremely high melting point and hardness due to its continuous three-dimensional network of covalent bonds.","accepted_answers":["silicon dioxide","sio2","quartz","silicon carbide","sic","boron nitride"],"semantic_fallback":true}'::jsonb,
    '8576d3b8a5deabd6bf39344ffd9a16f5e35c58142288fae64608cc1439002c59'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

  INSERT INTO public.source_cards (subject, unit, unit_exam_weight_pct, deck, type, difficulty, tags, source, reviewed, visual, content, content_hash)
  VALUES (
    'AP Chemistry',
    'Unit 2: Molecular and Ionic Compound Structure and Properties',
    9,
    'Types of Solids',
    'fr_numeric',
    'medium',
    ARRAY['covalent_network_solid','bond_energy','sublimation'],
    'ced_generated',
    true,
    NULL,
    '{"stem":"A small covalent network solid fragment contains {{a}} covalent bonds, each with a bond energy of {{b}} kJ/mol. Assuming all bonds must be broken to vaporize the solid, how much total energy (in kJ) is required?","params":{"a":{"min":2,"max":8,"step":2},"b":{"min":300,"max":500,"step":50}},"answer_formula":"a * b","precision":0,"unit":"kJ","tolerance":0,"semantic_fallback":false}'::jsonb,
    '8106263339641f12f09913a996be5d881f54863e1370571082096ed4dd4d32fc'
  )
  ON CONFLICT (content_hash) DO UPDATE SET reviewed = true
  RETURNING id INTO v_card_id;

END $$;