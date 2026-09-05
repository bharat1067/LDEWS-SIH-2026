import React, { createContext, useContext, useState, useEffect } from 'react';
import { translations } from './translations.js';

const LanguageContext = createContext();

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};

export const LanguageProvider = ({ children }) => {
  const [language, setLanguageState] = useState(() => {
    try {
      const saved = localStorage.getItem('ldews-language');
      if (saved && ['en', 'hi', 'mr'].includes(saved)) {
        return saved;
      }
    } catch {
      // Fallback if localStorage is restricted
    }
    return 'en';
  });

  const setLanguage = (newLang) => {
    if (!['en', 'hi', 'mr'].includes(newLang)) return;
    setLanguageState(newLang);
    try {
      localStorage.setItem('ldews-language', newLang);
    } catch {
      // Ignore write errors
    }
  };

  // Helper function to resolve dot-notated keys e.g. "farmer.bannerTitle"
  const t = (path, fallback = '', params = {}) => {
    // For 'mr' (Marathi scaffolded), fallback to Hindi or English if specific key missing
    const activeDict = translations[language] || translations.en;
    const parts = path.split('.');
    let cur = activeDict;

    for (const p of parts) {
      if (cur && typeof cur === 'object' && p in cur) {
        cur = cur[p];
      } else {
        cur = undefined;
        break;
      }
    }

    if (cur === undefined && language !== 'en') {
      // Try English fallback
      let enCur = translations.en;
      for (const p of parts) {
        if (enCur && typeof enCur === 'object' && p in enCur) {
          enCur = enCur[p];
        } else {
          enCur = undefined;
          break;
        }
      }
      cur = enCur;
    }

    if (cur === undefined) {
      return fallback || path;
    }

    if (typeof cur === 'string' && params && Object.keys(params).length > 0) {
      return Object.entries(params).reduce((str, [k, v]) => {
        return str.replace(new RegExp(`\\{${k}\\}`, 'g'), v);
      }, cur);
    }

    return cur;
  };

  const translateDisease = (diseaseName) => {
    if (!diseaseName) return '';
    const dict = translations[language]?.diseases || translations.en.diseases;
    return dict[diseaseName] || translations.en.diseases[diseaseName] || diseaseName;
  };

  const translateStatus = (status) => {
    if (!status) return '';
    const dict = translations[language]?.statuses || translations.en.statuses;
    return dict[status] || translations.en.statuses[status] || status;
  };

  const translateSpecies = (species) => {
    if (!species) return '';
    const dict = translations[language]?.species || translations.en.species;
    return dict[species] || translations.en.species[species] || species;
  };

  const symptomPresets = translations[language]?.symptomPresets || translations.en.symptomPresets;

  return (
    <LanguageContext.Provider
      value={{
        language,
        setLanguage,
        t,
        translateDisease,
        translateStatus,
        translateSpecies,
        symptomPresets
      }}
    >
      {children}
    </LanguageContext.Provider>
  );
};
